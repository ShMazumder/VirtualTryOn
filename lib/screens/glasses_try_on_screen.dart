import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/glasses_model.dart';

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

  final List<String> _glassesAssets = [
    'assets/glasses/glasses_0.png',
    'assets/glasses/glasses_1.png',
    'assets/glasses/glasses_2.png',
    'assets/glasses/glasses_3.png',
    'assets/glasses/glasses_4.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController.initialize();
      _cameraController.startImageStream(_processCameraImage);

      setState(() => _isInitialized = true);
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || !mounted) return;
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
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white),
              ),
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
    if (_faces.isEmpty) return Container();

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
                margin: EdgeInsets.symmetric(horizontal: 8),
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
                    SizedBox(height: 4),
                    Text(
                      glasses.name,
                      style: TextStyle(
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
