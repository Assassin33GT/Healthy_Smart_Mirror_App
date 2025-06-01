import 'package:demo/MostlyReviewButtons/diet_button.dart';
import 'package:demo/MostlyReviewButtons/skin_analysis_button.dart';
import 'package:demo/MostlyReviewButtons/control_mirror.dart';
import 'package:demo/home_page.dart';
import 'package:flutter/material.dart';

class MostlyReview extends StatelessWidget {
  const MostlyReview({super.key});

  @override
  Widget build(context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DietButton()),
                );
              },
              child: AnimatedContainer(
                width: screenWidth * 0.37,
                height: screenHeight * 0.2,
                duration: const Duration(milliseconds: 2000),
                decoration: BoxDecoration(
                  color: color1 == Color.fromARGB(255, 126, 95, 227) ? Color.fromARGB(188, 124, 77, 255) : const Color.fromARGB(112, 101, 63, 207),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Diet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Plans",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 13.0),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ControlMirror()),
                  );
                },
                child: AnimatedContainer(
                  width: screenWidth * 0.37,
                  height: screenHeight * 0.1,
                  duration: const Duration(milliseconds: 2000),
                  decoration: BoxDecoration(
                    color: color1 == Color.fromARGB(255, 126, 95, 227) ? Color.fromARGB(188, 124, 77, 255) : const Color.fromARGB(112, 101, 63, 207),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Mirror",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Control",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              AnimatedContainer(
                width: screenWidth * 0.37,
                height: screenHeight * 0.1,
                duration: const Duration(milliseconds: 2000),
                decoration: BoxDecoration(
                  color: color1 == Color.fromARGB(255, 126, 95, 227) ? Color.fromARGB(188, 124, 77, 255) : const Color.fromARGB(112, 101, 63, 207),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "7",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Day",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SkinAnalysisButton(),
                          ),
                    );
                  },
                  child: AnimatedContainer(
                    width: screenWidth * 0.37,
                    height: screenHeight * 0.2,
                    duration: const Duration(milliseconds: 2000),
                    decoration: BoxDecoration(
                      color: color1 == Color.fromARGB(255, 126, 95, 227) ? Color.fromARGB(188, 124, 77, 255) : const Color.fromARGB(112, 101, 63, 207),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Skin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Analysis",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
