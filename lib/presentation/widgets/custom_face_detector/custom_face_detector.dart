import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gmlkit_liveness/data/models/image_data.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_camera_preview/custom_camera_preview.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_face_detector/worker.dart';
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
  DetectorWorker? worker;

  @override
  void initState() {
    super.initState();
    _initWorker();
  }

  _initWorker() async {
    worker = await DetectorWorker.spawn();
  }

  @override
  void dispose() {
    super.dispose();
    if (worker != null) worker?.close();
  }

  Future<void> _runAnalysisPipeline(CameraImageMetaData metaData) async {
    if (_isBusy || worker == null) return;
    _isBusy = true;

    final (analysisData) = await worker?.processImage(metaData);
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

  @override
  Widget build(BuildContext context) {
    return CustomCameraPreview(
      onImage: _runAnalysisPipeline,
      customPaint: widget.customPaint,
    );
  }
}
