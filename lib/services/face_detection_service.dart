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

  ValueNotifier<List<Face>> faces = ValueNotifier([]);

  Future<List<Face>> processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      print("No face.");
      return [];
    }
  final detectedFaces = await _faceDetector.processImage(inputImage);
    faces.value = detectedFaces;
    return detectedFaces;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
        if (image == null) {
          print("CameraImage is null");
          return null;
        }
    try {
        final format = InputImageFormatValue.fromRawValue(image.format.raw);
        if (format == null) {
          print('Unsupported image format: ${image.format.raw}');
          final correctFormat = image.format.raw == 87
              ? InputImageFormat.nv21
              : InputImageFormat.yuv_420_888;
          if(image.format.raw == 87 || image.format.raw == 842094169) {
            return InputImage.fromBytes(
                bytes: image.planes[0].bytes,
                metadata: InputImageMetadata(
                    size: Size(image.width.toDouble(), image.height.toDouble()),
                    rotation: InputImageRotation.rotation0deg,
                    format: correctFormat,
                    bytesPerRow: image.planes[0].bytesPerRow,
                ),
              );
          } else {
            return null;
          }
      }

      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      print('Image conversion error: $e');
      return null;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

final faceDetectionService = FaceDetectionService();