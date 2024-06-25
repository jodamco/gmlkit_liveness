import 'package:flutter/material.dart';
import 'package:gmlkit_liveness/presentation/live_data_page/angle_display.dart';
import 'package:gmlkit_liveness/presentation/live_data_page/angles_chart.dart';
import 'package:gmlkit_liveness/presentation/live_data_page/emotion_display.dart';
import 'package:gmlkit_liveness/presentation/widgets/custom_face_detector/custom_face_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LiveDataPage extends StatefulWidget {
  const LiveDataPage({super.key});

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  List<double> eulerAngles = [0, 0, 0];
  int lastAnalysisTimestamp = DateTime.now().millisecondsSinceEpoch;
  List<int> analysisLatencyStack = [];
  Face? faceData;

  List<List<double>> anglesData = [];

  _onAnalysisData((InputImage, List<Face>) analysisData) {
    final face = analysisData.$2[0];
    if(!mounted) return;
    setState(() {
      analysisLatencyStack
          .add(DateTime.now().millisecondsSinceEpoch - lastAnalysisTimestamp);

      lastAnalysisTimestamp = DateTime.now().millisecondsSinceEpoch;
      if (analysisLatencyStack.length > 20) analysisLatencyStack.removeAt(0);

      faceData = analysisData.$2[0];

      eulerAngles = [
        face.headEulerAngleX!,
        face.headEulerAngleY!,
        face.headEulerAngleZ!
      ];

      anglesData.add(eulerAngles);
      if (anglesData.length > 25) anglesData.removeAt(0);
    });
  }

  double get analysisLatency {
    return analysisLatencyStack.isNotEmpty
        ? analysisLatencyStack.reduce((prev, next) => prev + next) /
            analysisLatencyStack.length
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live data"),
      ),
      body: Stack(
        children: [
          CustomFaceDetector(onAnalysisData: _onAnalysisData),
          Positioned(
            top: 24,
            left: 24,
            child: Text(
              "${analysisLatency.toStringAsFixed(2)} ms",
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 26, 255, 0),
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 24,
            child: EmotionDisplay(faceData: faceData),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: AnglesDisplay(angles: eulerAngles),
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: AnglesChart(
              anglesData: anglesData,
            ),
          ),
        ],
      ),
    );
  }
}
