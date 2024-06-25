import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class EmotionDisplay extends StatelessWidget {
  final Face? faceData;

  const EmotionDisplay({super.key, required this.faceData});

  String get currentEmotion {
    if (faceData == null) {
      return "😵";
    } else if (isWinking(faceData!)) {
      return "😉";
    } else if (hasEyesOpen(faceData!) && isSmilling(faceData!)) {
      return "😀";
    } else if (!hasEyesOpen(faceData!) && isSmilling(faceData!)) {
      return "😄";
    } else if (!hasEyesOpen(faceData!)) {
      return "😴";
    } else {
      return "😐";
    }
  }

  bool isRightEyeOpen(Face data) =>
      data.rightEyeOpenProbability != null &&
      data.rightEyeOpenProbability! > 0.6;
  bool isLeftEyeOpen(Face data) =>
      data.leftEyeOpenProbability != null && data.leftEyeOpenProbability! > 0.6;
  bool hasEyesOpen(Face data) => isRightEyeOpen(data) && isLeftEyeOpen(data);
  bool isWinking(Face data) => isRightEyeOpen(data) ^ isLeftEyeOpen(data);
  bool isSmilling(Face data) =>
      data.smilingProbability != null && data.smilingProbability! > 0.6;

  @override
  Widget build(BuildContext context) {
    return Text(
      currentEmotion,
      style: const TextStyle(fontSize: 24),
    );
  }
}
