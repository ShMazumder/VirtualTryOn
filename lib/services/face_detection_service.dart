import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  final ValueNotifier<List<Face>> faces = ValueNotifier([]);

  Future<List<Face>> processCameraImage(CameraImage image) async {
    final inputImage = _convertToInputImage(image);
    if (inputImage == null) return [];

    try {
      final detectedFaces = await _faceDetector.processImage(inputImage);
      faces.value = detectedFaces;
      return detectedFaces;
    } catch (e) {
      debugPrint('Face detection failed: $e');
      return [];
    }
  }

  InputImage? _convertToInputImage(CameraImage image) {
    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      final supportedFormat = format ?? _fallbackFormat(image.format.raw);

      if (supportedFormat == null) {
        debugPrint('Unsupported image format: ${image.format.raw}');
        return null;
      }

      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: supportedFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Failed to convert camera image: $e');
      return null;
    }
  }

  InputImageFormat? _fallbackFormat(int rawFormat) {
    switch (rawFormat) {
      case 87:
        return InputImageFormat.nv21;
      case 842094169:
        return InputImageFormat.yuv_420_888;
      default:
        return null;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

// Global instance
final faceDetectionService = FaceDetectionService();
