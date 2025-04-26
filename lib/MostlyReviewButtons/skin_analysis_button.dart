import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SkinAnalysisButton extends StatefulWidget{
  const SkinAnalysisButton({super.key});

  @override
  State<SkinAnalysisButton> createState() => _SkinAnalysisButtonState();
}

class _SkinAnalysisButtonState extends State<SkinAnalysisButton> {
  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Analysis")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 126, 95, 227),
              Color.fromARGB(255, 60, 30, 182),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text("Use the camera button to analyze your skin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(188, 124, 77, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () {
                  //CameraDevice camera = CameraDevice.front;
                  ImagePicker imagePicker = ImagePicker();
                  //final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                },
                child: const Icon(Icons.camera_alt, size: 30, color: Colors.white),
              ),
            ],
          )
          ),
    ),
      );
  }
}