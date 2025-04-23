import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io'; // Import dart:io
import '../models/glasses_model.dart';
import 'widgets/face_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/face_detection_service.dart';
import 'widgets/glasses_selector.dart'; // Import GlassesSelector

class GlassesTryOnScreen extends StatefulWidget {
  const GlassesTryOnScreen({Key? key}) : super(key: key);

  @override
  State<GlassesTryOnScreen> createState() => _GlassesTryOnScreenState();
}

class _GlassesTryOnScreenState extends State<GlassesTryOnScreen> {
  late CameraController _cameraController;
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  int _selectedGlasses = 0;
  bool _cameraPermissionGranted = false;
  static const String initializingCamera = 'Initializing Camera...';
  static const String waitingCameraPermission =
      'Waiting for camera permission...';

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    if (kIsWeb) {
      if (await Permission.camera.isGranted) {
        setState(() => _cameraPermissionGranted = true);
        _initializeCamera();
      } else {
        final status = await Permission.camera.request();
        if (status.isGranted) {
          setState(() => _cameraPermissionGranted = true);
          _initializeCamera();
        } else {
          _showCameraError(
              'Camera permission not granted on web. Please enable it in your browser settings.');
        }
      }
      return;
    }

    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        setState(() => _cameraPermissionGranted = true);
        _initializeCamera();
      } else {
        _showCameraError(
            'Camera permission not granted. Please enable it in your device settings.');
      }
    } else {
      setState(() => _cameraPermissionGranted = true);
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // First get available cameras
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _showCameraError('No cameras available on this device');
        return;
      }
      if (kIsWeb) {
        final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first);
        // Web-specific initialization with lower resolution
        // Consider using a lower resolution for web for performance reasons

        // You might also want to disable audio for web
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.low,
          enableAudio: false,
        );
      } else {
        // Mobile initialization
        _cameraController = CameraController(
          cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ),
          ResolutionPreset.medium,
        );
      }

      await _cameraController.initialize();

      if (!kIsWeb) {
        _cameraController
            .startImageStream(_faceDetectionService.processCameraImage);
      }
      setState(() => _isInitialized = true); // Camera initialized successfully
    } on CameraException catch (e) {
      String errorDescription;
      switch (e.code) {
        default:
          errorDescription =
              'An unknown camera error occurred: ${e.description}';
      }
      setState(() => _isInitialized = false); // Camera initialization failed
      _showCameraError(e.toString());
    }
  }

  void _showCameraError(String errorMessage) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage.isNotEmpty
              ? 'Camera access is required. Error: $errorMessage'
              : 'Camera access is required for virtual try-on',
        ),
        action: kIsWeb && !_cameraPermissionGranted
            ? SnackBarAction(label: 'Grant', onPressed: _checkCameraPermission)
            : !kIsWeb && Platform.isAndroid
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

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  bool _isInitialized = false;

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
                    ? initializingCamera
                    : waitingCameraPermission,
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
          FaceOverlay(
            selectedGlasses: _selectedGlasses,
            faceDetectionService: _faceDetectionService,
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GlassesSelector(
                  glassesList: glassesList,
                  selectedGlasses: _selectedGlasses,
                  onGlassesSelected: (index) {
                    setState(() => _selectedGlasses = index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
