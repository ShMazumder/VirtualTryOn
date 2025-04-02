import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_web/camera_web.dart' if (dart.library.html) 'dart:html';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/glasses_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GlassesTryOnScreen extends StatefulWidget {
  const GlassesTryOnScreen({super.key});

  @override
  GlassesTryOnScreenState createState() => GlassesTryOnScreenState();
}

class GlassesTryOnScreenState extends State<GlassesTryOnScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  List<Face> _faces = [];
  bool _isInitialized = false;
  int _selectedGlasses = 0;
  bool _isDetecting = false;
  bool _cameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<void> _checkCameraPermission() async {
    if (kIsWeb) {
      // Web handles permissions differently
      _initializeCamera();
      return;
    }

    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        setState(() => _cameraPermissionGranted = true);
        _initializeCamera();
      } else {
        _showCameraError();
      }
    } else {
      setState(() => _cameraPermissionGranted = true);
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (kIsWeb) {
        // Web-specific implementation
        _cameraController = CameraController(
          const CameraDescription(
            name: 'webcam',
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 0,
          ),
          ResolutionPreset.low,
        );
      } else {
        // Mobile implementation
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          throw Exception('No cameras available');
        }
        
        _cameraController = CameraController(
          cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ),
          ResolutionPreset.medium,
        );
      }

      await _cameraController.initialize();
      
      // Only start image stream for mobile
      if (!kIsWeb) {
        _cameraController.startImageStream(_processCameraImage);
      }
      
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Camera initialization error: $e');
      setState(() => _isInitialized = false);
      _showCameraError();
    }
  }

  void _showCameraError() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Camera access is required for virtual try-on'),
        action: kIsWeb 
            ? null 
            : SnackBarAction(
                label: 'Settings',
                onPressed: () async {
                  await openAppSettings();
                  if (mounted) {
                    _checkCameraPermission();
                  }
                },
              ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || !mounted || kIsWeb) return;
    _isDetecting = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        setState(() => _faces = faces);
      }
    } catch (e) {
      print('Face detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

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

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _cameraPermissionGranted 
                    ? 'Initializing Camera...' 
                    : 'Waiting for camera permission...',
                style: const TextStyle(color: Colors.white),
              ),
              if (!_cameraPermissionGranted && !kIsWeb) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkCameraPermission,
                  child: const Text('Grant Permission'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          _buildFaceOverlay(),
          _buildGlassesSelector(),
        ],
      ),
    );
  }

  Widget _buildFaceOverlay() {
    if (_faces.isEmpty || kIsWeb) return Container();

    final face = _faces.first;
    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
    final noseBase = face.landmarks[FaceLandmarkType.noseBase]?.position;

    if (leftEye == null || rightEye == null || noseBase == null) {
      return Container();
    }

    final currentGlasses = glassesList[_selectedGlasses];
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
  }

  Widget _buildGlassesSelector() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: glassesList.length,
          itemBuilder: (context, index) {
            final glasses = glassesList[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedGlasses = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 100,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedGlasses == index
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        glasses.assetPath,
                        width: 80,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      glasses.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }
}