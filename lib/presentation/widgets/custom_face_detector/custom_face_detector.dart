import 'dart:isolate';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmlkit_liveness/data/models/image_data.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_camera_preview/custom_camera_preview.dart';
import 'package:gmlkit_liveness/presentation/widgets/face_detector_painter/face_detector_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CustomFaceDetector extends StatefulWidget {
  const CustomFaceDetector({super.key});
  @override
  State<CustomFaceDetector> createState() => _CustomFaceDetectorState();
}

class _CustomFaceDetectorState extends State<CustomFaceDetector> {
  final cameraLensDirection = CameraLensDirection.front;
  CustomPaint? _customPaint;
  int midTimeToExecuteMs = 0;
  int processCount = 0;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _processImage(ImageData imageData) async {
    if (_isBusy) return;
    _isBusy = true;
    final stopwatch = Stopwatch()..start();

    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

    final analyticData = await Isolate.run<Map<String, dynamic>>(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      final inputImage = imageData.inputImageFromCameraImage(imageData);
      if (inputImage == null) return {"faces": null, "image": inputImage};

      final FaceDetector faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      return {"faces": faces, "image": inputImage};
    });

    if (analyticData['faces'] == null || analyticData['image'] == null) {
      midTimeToExecuteMs += stopwatch.elapsedMilliseconds;
      processCount++;

      _isBusy = false;

      return;
    }

    if ((analyticData['image'] as InputImage).metadata?.size == null ||
        (analyticData['image'] as InputImage).metadata?.rotation == null) {
      midTimeToExecuteMs += stopwatch.elapsedMilliseconds;
      processCount++;

      _isBusy = false;

      return;
    }

    final painter = FaceDetectorPainter(
      (analyticData['faces'] as List<Face>),
      (analyticData['image'] as InputImage).metadata!.size,
      (analyticData['image'] as InputImage).metadata!.rotation,
      imageData.lensDirection,
    );

    _customPaint = CustomPaint(painter: painter);

    midTimeToExecuteMs += stopwatch.elapsedMilliseconds;
    processCount++;

    _isBusy = false;

    if (mounted) {
      setState(() {});
    }
  }

  // Future<void> _processImage(ImageData imageData) async {
  //   if (_isBusy) return;
  //   _isBusy = true;

  //   RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

  //   final (faces, inputImage) =
  //       await Isolate.run<(List<Face>, InputImage?)>(() async {
  //     BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  //     final inputImage = imageData.inputImageFromCameraImage(imageData);
  //     if (inputImage == null) {
  //       return Future.value(
  //         ([], inputImage) as FutureOr<(List<Face>, InputImage?)>?,
  //       );
  //     }

  //     final FaceDetector faceDetector = FaceDetector(
  //       options: FaceDetectorOptions(
  //         enableContours: true,
  //         enableLandmarks: true,
  //       ),
  //     );

  //     final faces = await faceDetector.processImage(inputImage);

  //     await faceDetector.close();

  //     return (faces, inputImage);
  //   });

  //   if (faces.isEmpty || inputImage == null) {
  //     _isBusy = false;
  //     return;
  //   }

  //   if (inputImage.metadata?.size == null ||
  //       inputImage.metadata?.rotation == null) {
  //     _isBusy = false;
  //     return;
  //   }

  //   final painter = FaceDetectorPainter(
  //     faces,
  //     inputImage.metadata!.size,
  //     inputImage.metadata!.rotation,
  //     imageData.lensDirection,
  //   );
  //   setState(() {
  //     _customPaint = CustomPaint(painter: painter);
  //   });

  //   // if (inputImage.metadata?.size != null &&
  //   //     inputImage.metadata?.rotation != null) {
  //   //   //    faces,
  //   //   // inputImage.metadata!.size,
  //   //   // inputImage.metadata!.rotation,
  //   // } else {
  //   //   String text = 'Faces found: ${faces.length}\n\n';
  //   //   for (final face in faces) {
  //   //     text += 'face: ${face.boundingBox}\n\n';
  //   //   }
  //   // }
  //   // debugPrint(
  //   //     'X: ${faces[0].headEulerAngleX} Y:${faces[0].headEulerAngleY} Z:${faces[0].headEulerAngleZ}');
  //   _isBusy = false;
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCameraPreview(
          onImage: _processImage,
          customPaint: _customPaint,
        ),
        Center(
          child: Text(
            "${(midTimeToExecuteMs / processCount).toStringAsFixed(2)} ms",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
