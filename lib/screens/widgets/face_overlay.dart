import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../models/glasses_model.dart';
import '../../services/face_detection_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FaceOverlay extends StatelessWidget {
  final FaceDetectionService faceDetectionService;
  final int selectedGlasses;

  const FaceOverlay({
    super.key,
    required this.selectedGlasses,
    required this.faceDetectionService,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: faceDetectionService.faces,
        builder: (context, child) {
      if (faceDetectionService.faces.value.isEmpty || kIsWeb) return Container();

      final face = faceDetectionService.faces.value.first;
      final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
      final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
      final noseBase = face.landmarks[FaceLandmarkType.noseBase]?.position;

      if (leftEye == null || rightEye == null || noseBase == null) {
        return Container();
      }

      final currentGlasses = glassesList[selectedGlasses];
      final eyeDistance = (rightEye.x - leftEye.x).abs();
      final glassesWidth = eyeDistance * 2.5 * currentGlasses.scaleFactor;
      final glassesHeight = glassesWidth * 0.4;

      return Positioned(
        left: leftEye.x - glassesWidth * 0.35,
        top: noseBase.y - glassesHeight * 0.5,
        child: Image.asset(
          currentGlasses.assetPath,
          width: glassesWidth,
          height: glassesHeight,
          fit: BoxFit.contain,
        ),
      );
    });
  }
}