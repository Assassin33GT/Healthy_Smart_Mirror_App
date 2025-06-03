import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/MostlyReviewButtons/diet_button.dart';
import 'package:demo/MostlyReviewButtons/skin_analysis_button.dart';
import 'package:demo/MostlyReviewButtons/control_mirror.dart';
import 'package:demo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MostlyReview extends StatefulWidget {
  const MostlyReview({super.key});

  @override
  State<MostlyReview> createState() => _MostlyReviewState();
}

int counter = 0;
String timeOfStart = '';

class _MostlyReviewState extends State<MostlyReview> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    fetchStartTime();
    super.initState();
  }

  Future updateCounter() async {
    String user = auth.currentUser!.uid;

    await firestore.collection('users').doc(user).update({
      'counter': counter,
      'timeOfStart': timeOfStart,
    });
  }

  Future<Map<String, dynamic>?> fetchStartTime() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
    String user = auth.currentUser!.uid;
    DocumentSnapshot snapshot =
        await firestore.collection('users').doc(user).get();

    Map<String,dynamic> save = snapshot.data() as Map<String, dynamic>;
    print(save['counter']);
    counter = int.parse(save['counter']);
    print(counter);
    timeOfStart = save['timeOfStart'];
    return snapshot.data() as Map<String, dynamic>;
  }

  void increaseCounter() async {
    DateTime currentDate = DateTime.now();
    Map<String, dynamic>? data = await fetchStartTime();
    timeOfStart = data!['timeOfStart'];
    counter = int.parse(data['counter']);
    DateTime savedDate = DateTime.parse(timeOfStart);
    counter = currentDate.difference(savedDate).inDays + 1;
  }

  @override
  Widget build(context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    fetchStartTime();
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
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
                  color:
                      color1 == Color.fromARGB(255, 126, 95, 227)
                          ? Color.fromARGB(188, 124, 77, 255)
                          : const Color.fromARGB(112, 101, 63, 207),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ControlMirror(),
                    ),
                  );
                },
                child: AnimatedContainer(
                  width: screenWidth * 0.37,
                  height: screenHeight * 0.1,
                  duration: const Duration(milliseconds: 2000),
                  decoration: BoxDecoration(
                    color:
                        color1 == Color.fromARGB(255, 126, 95, 227)
                            ? Color.fromARGB(188, 124, 77, 255)
                            : const Color.fromARGB(112, 101, 63, 207),
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (counter == 0) {
                      counter = 1;
                      timeOfStart = DateTime.now().toString();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Counter Started!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Reset Counter to Start again!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                    increaseCounter();
                    updateCounter();
                  });
                },
                child: AnimatedContainer(
                  width: screenWidth * 0.37,
                  height: screenHeight * 0.1,
                  duration: const Duration(milliseconds: 2000),
                  decoration: BoxDecoration(
                    color:
                        color1 == Color.fromARGB(255, 126, 95, 227)
                            ? Color.fromARGB(188, 124, 77, 255)
                            : const Color.fromARGB(112, 101, 63, 207),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        counter != 0 ?
                        Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  counter = 0;
                                  timeOfStart = '';
                                });
                                updateCounter();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Counter Reset!"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Icon(Icons.replay_outlined, size: 13,color: Color.fromARGB(255, 155, 39, 176),),
                            ),
                          ),
                        ) : Container(),
                        Text(
                          counter == 0 ? "Counter" : counter.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          counter == 0 ? "Start" : "Day",
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
                  onTap: () {
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
                      color:
                          color1 == Color.fromARGB(255, 126, 95, 227)
                              ? Color.fromARGB(188, 124, 77, 255)
                              : const Color.fromARGB(112, 101, 63, 207),
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
