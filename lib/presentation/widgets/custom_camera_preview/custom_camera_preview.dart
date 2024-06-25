import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gmlkit_liveness/data/models/image_data.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_camera_preview/preview_placeholder.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCameraPreview extends StatefulWidget {
  final Function(CameraImageMetaData inputImage)? onImage;
  final CustomPaint? customPaint;
  final VoidCallback? onCameraFeedReady;

  const CustomCameraPreview({
    super.key,
    this.onImage,
    this.onCameraFeedReady,
    this.customPaint,
  });

  @override
  State<CustomCameraPreview> createState() => _CustomCameraPreviewState();
}

class _CustomCameraPreviewState extends State<CustomCameraPreview> {
  CameraDescription? selectedCamera;
  CameraController? _controller;
  bool hasPermissions = false;
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _askForPermissions();
      await _getAvailableCameras();
      await _startLiveFeed();
    } catch (_) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _askForPermissions() async {
    PermissionStatus permissionStatus;
    bool newPermissionStatus = false;

    permissionStatus = await Permission.camera.status;
    if (permissionStatus.isPermanentlyDenied) {
      newPermissionStatus = false;
    } else if (permissionStatus.isGranted || permissionStatus.isLimited) {
      newPermissionStatus = true;
    } else if (permissionStatus.isDenied) {
      newPermissionStatus = await Permission.camera.request().isGranted;
    }

    setState(() {
      hasPermissions = newPermissionStatus;
    });
  }

  Future<void> _getAvailableCameras() async {
    final cameras = await availableCameras();
    setState(() {
      selectedCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
    });
  }

  Future<void> _startLiveFeed() async {
    if (selectedCamera == null) {
      setState(() {
        hasError = true;
      });
      return;
    }

    _controller = CameraController(
      selectedCamera!,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller?.initialize();
    _controller?.startImageStream(_onImage);

    if (widget.onCameraFeedReady != null) {
      widget.onCameraFeedReady!();
    }
  }

  void _onImage(CameraImage image) {
    if (_controller == null) return;

    if (widget.onImage != null) {
      widget.onImage!(
        CameraImageMetaData(
          lensDirection: CameraLensDirection.front,
          deviceOrientation: _controller!.value.deviceOrientation,
          sensorOrientation: selectedCamera!.sensorOrientation,
          cameraImage: image,
        ),
      );
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Widget display() {
    if (isLoading) {
      return PreviewPlaceholder.loadingPreview();
    } else if (hasError) {
      return PreviewPlaceholder.previewError(
        onRetry: _initialize,
      );
    } else if (!hasPermissions) {
      return PreviewPlaceholder.noPermission(
        onAskForPermissions: _initialize,
      );
    } else {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: CameraPreview(
              _controller!,
              child: widget.customPaint,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: display(),
    );
  }
}
