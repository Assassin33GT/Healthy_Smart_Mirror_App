import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SkinAnalysisButton extends StatefulWidget {
  const SkinAnalysisButton({super.key});

  @override
  State<SkinAnalysisButton> createState() => _SkinAnalysisButtonState();
}

class _SkinAnalysisButtonState extends State<SkinAnalysisButton> {
  XFile? image;
  int i = 0;

  // Future<void> classifySkin() async {
  // final interpreter = await Interpreter.fromAsset('skin_model.tflite');
  // var input = image; // Your preprocessing
  // var output = List.filled(1, 0).reshape([1, 2]);
  // interpreter.run(input, output);
  // print(output); // Prediction result
  // }

  @override
  Widget build(context) {
    Future<void> _pickImage() async {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
      );

      setState(() {
        image = pickedImage;
        i++;
      });

      print(image?.path);
    }

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
              Text(
                "Use the camera button to analyze your skin",
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
                onPressed: _pickImage,
                child: const Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              if (i > 0)
                Text(
                  "Image captured successfully!",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 5),
              image != null
                  ? Row(
                    children: [
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(12),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    "Result",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Your skin type has been detected as normal with minimal wrinkles.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Hydration: 78% | Pores: Slightly Enlarged | Acne: No major breakouts detected",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : const SizedBox(),
              
            ],
          ),
        ),
      ),
    );
  }
}
