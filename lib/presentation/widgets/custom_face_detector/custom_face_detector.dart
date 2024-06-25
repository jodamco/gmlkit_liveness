import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmlkit_liveness/data/models/image_data.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_camera_preview/custom_camera_preview.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CustomFaceDetector extends StatefulWidget {
  final ValueChanged<(InputImage, List<Face>)>? onAnalysisData;
  final CustomPaint? customPaint;
  const CustomFaceDetector({
    super.key,
    this.customPaint,
    this.onAnalysisData,
  });
  @override
  State<CustomFaceDetector> createState() => _CustomFaceDetectorState();
}

class _CustomFaceDetectorState extends State<CustomFaceDetector> {
  final cameraLensDirection = CameraLensDirection.front;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _runAnalysisPipeline(CameraImageMetaData metaData) async {
    if (_isBusy) return;
    _isBusy = true;

    final (analysisData) = await _processImage(metaData);
    if (analysisData != null && widget.onAnalysisData != null) {
      widget.onAnalysisData!(analysisData);
    }

    _isBusy = false;

    // paint(analysisData, metaData.lensDirection);
  }

  // paint((InputImage, List<Face>)? data, CameraLensDirection lensDirection) {
  //   if (data == null) return;

  //   final painter = FaceDetectorPainter(
  //     data.$2,
  //     data.$1.metadata!.size,
  //     data.$1.metadata!.rotation,
  //     lensDirection,
  //   );

  //   _customPaint = CustomPaint(painter: painter);
  // }

  Future<(InputImage, List<Face>)?> _processImage(
    CameraImageMetaData metaData,
  ) async {
    final inputImage = await parseMetaData(metaData);

    if (inputImage == null ||
        inputImage.metadata?.size == null ||
        inputImage.metadata?.rotation == null) return null;

    final faceList = await runFaceDetection(inputImage);
    if (faceList.isEmpty) return null;

    return (inputImage, faceList);
  }

  Future<InputImage?> parseMetaData(CameraImageMetaData metaData) async {
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    return await Isolate.run<InputImage?>(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      final inputImage = metaData.inputImageFromCameraImageMetaData(metaData);
      return inputImage;
    });
  }

  Future<List<Face>> runFaceDetection(InputImage inputImage) async {
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    return await Isolate.run<List<Face>>(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      final FaceDetector faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
          enableTracking: true,
          enableClassification: true
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();
      return faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCameraPreview(
      onImage: _runAnalysisPipeline,
      customPaint: widget.customPaint,
    );
  }
}
