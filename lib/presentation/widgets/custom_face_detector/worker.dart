import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:gmlkit_liveness/data/models/image_data.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DetectorWorker {
  final Isolate _isolateRef;
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  Future<(InputImage, List<Face>)?> processImage(
      CameraImageMetaData metaData) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<(InputImage, List<Face>)?>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, metaData));
    return await completer.future;
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) {
        _responses.close();
        _isolateRef.kill();
      }
    }
  }

  static Future<DetectorWorker> spawn() async {
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    final Isolate isolateRef;

    try {
      var rootToken = RootIsolateToken.instance!;
      isolateRef = await Isolate.spawn<(SendPort, RootIsolateToken)>(
          _startRemoteIsolate, (initPort.sendPort, rootToken));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return DetectorWorker._(receivePort, sendPort, isolateRef);
  }

  DetectorWorker._(this._responses, this._commands, this._isolateRef) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  static void _startRemoteIsolate((SendPort, RootIsolateToken) startData) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(startData.$2);

    final receivePort = ReceivePort();
    startData.$1.send(receivePort.sendPort);
    final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableTracking: true,
        enableClassification: true,
      ),
    );
    _handleCommandsToIsolate(receivePort, startData.$1, faceDetector);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete((response as (InputImage, List<Face>)?));
    }

    if (_closed && _activeRequests.isEmpty) {
      _responses.close();
      _isolateRef.kill();
    }
  }

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
    FaceDetector detector,
  ) {
    receivePort.listen((message) async {
      if (message == 'shutdown') {
        await detector.close();
        receivePort.close();
        return;
      }
      final (int id, data) = message as (int, CameraImageMetaData);
      try {
        final inputImage = data.inputImageFromCameraImageMetaData();

        if (inputImage == null ||
            inputImage.metadata?.size == null ||
            inputImage.metadata?.rotation == null) {
          sendPort.send((id, null));
          return;
        }

        final faceList = await detector.processImage(inputImage);

        if (faceList.isEmpty) {
          sendPort.send((id, null));
          return;
        }

        sendPort.send((id, (inputImage, faceList)));
      } catch (e) {
        sendPort.send((id, RemoteError(e.toString(), '')));
      }
    });
  }
}
