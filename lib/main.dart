import 'package:flutter/material.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_face_detector/custom_face_detector.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: CustomFaceDetector(),
      ),
    );
  }
}
