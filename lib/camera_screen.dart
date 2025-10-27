import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.camera,
    required this.imageController,
  });

  final CameraDescription camera;
  final ImageController imageController;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class ImageController {
  File? _image;

  File? get image => _image;

  void setImage(File newImage) {
    _image = newImage;
  }

  void clear() {
    _image = null;
  }
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;


  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    await textRecognizer.close();
    return recognizedText.text;
  }

  String extractNIK(String text) {
    final regex = RegExp(r'\d+'); // Matches sequences of digits
    final matches = regex.allMatches(text);
    // Join all found digit sequences with commas, or modify logic as needed
    return matches.map((m) => m.group(0)).join(', ');
  }

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photograph Microchip #')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Ensure the camera is initialized
            await _initializeControllerFuture;

            // Get the directory to save the picture
            final directory = await getApplicationDocumentsDirectory();
            final imagePath = path.join(
              directory.path,
              'image_${DateTime.now()}.png',
            );

            // Capture the image
            final XFile image = await _controller.takePicture();

            // Store the image in controller
            widget.imageController.setImage(File(image.path));

            // Recognize OCR text
            final recognizedText = await recognizeText(File(image.path));

            // Extract NIK/NPWP
            final number = extractNIK(recognizedText);

            // Print or handle the number as needed
            print('Recognized number: $number');

            await _controller.dispose();

            if (!mounted) return;
            Navigator.of(context).pop(number);
          } catch (e) {
            print('Error taking picture: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
