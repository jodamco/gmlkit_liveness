import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:gmlkit_liveness/data/models/camera_image.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraImageMetaData {
  final CameraLensDirection lensDirection;
  final DeviceOrientation deviceOrientation;
  final int sensorOrientation;
  final CameraImage cameraImage;
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  CameraImageMetaData({
    required this.lensDirection,
    required this.deviceOrientation,
    required this.sensorOrientation,
    required this.cameraImage,
  });

  InputImage? inputImageFromCameraImageMetaData() {
    InputImageRotation? rotation = _getPlatformRotation();
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(
      cameraImage.format.raw,
    );
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.yuv_420_888) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    final plane = cameraImage.planes.first;

    return InputImage.fromBytes(
      bytes: cameraImage.getNv21Uint8List(),
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  InputImageRotation? _getPlatformRotation() {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[deviceOrientation];
      if (rotationCompensation == null) return null;
      if (lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      return InputImageRotationValue.fromRawValue(rotationCompensation);
    } else {
      return null;
    }
  }
}
