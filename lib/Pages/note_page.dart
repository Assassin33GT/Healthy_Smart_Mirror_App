import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/main.dart';
import 'package:demo/widgets/curvednavigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController noteController = TextEditingController();
  String note1 = "";
  String note2 = "";
  String note3 = "";
  int noteNumber = 1;
  @override
  void initState() {
    super.initState();
    getNote();
  }

  void getNote() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth user = FirebaseAuth.instance;
    String userId = user.currentUser!.uid;

    DocumentSnapshot snapshot = await firestore
                                  .collection("users")
                                  .doc(userId)
                                  .get();
    Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
    print(data);

    if(data["note1"] != null){
      setState(() {
        note1 = data["note1"];  
      });
    }
    if(data["note2"] != null){
      setState(() {
        note2 = data["note2"];  
      });
    }
    if(data["note3"] != null){
      setState(() {
        note3 = data["note3"];  
      });
    }
  }

  void saveNote() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth user = FirebaseAuth.instance;
    String userId = user.currentUser!.uid;
    if (note1.isNotEmpty) {
      await firestore.collection("users").doc(userId).update({"note1": note1});
    }
    if (note2.isNotEmpty) {
      await firestore.collection("users").doc(userId).update({"note2": note2});
    }
    if (note3.isNotEmpty) {
      await firestore.collection("users").doc(userId).update({"note3": note3});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: "Enter Note",
                  fillColor:
                      color1 != Colors.black87 ? Colors.white : Colors.white38,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: screenWidth * 0.155,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color1 != Colors.black87 ? Colors.amber : const Color.fromARGB(255, 188, 142, 3),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (noteNumber > 1) {
                          setState(() {
                            noteNumber--;
                          });
                        }
                      },
                      child: Icon(Icons.arrow_left_outlined),
                    ),
                    Text(
                      "$noteNumber",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (noteNumber < 3) {
                          setState(() {
                            noteNumber++;
                          });
                        }
                      },
                      child: Icon(Icons.arrow_right_outlined),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send_outlined,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  if (noteNumber == 1) {
                    setState(() {
                      note1 = noteController.text;
                      saveNote();
                      noteController.clear();
                    });
                  } else if (noteNumber == 2) {
                    setState(() {
                      note2 = noteController.text;
                      saveNote();
                      noteController.clear();
                    });
                  } else if (noteNumber == 3) {
                    setState(() {
                      note3 = noteController.text;
                      saveNote();
                      noteController.clear();
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Enter a Note!"),
                      duration: Duration(seconds: 1),
                      backgroundColor: const Color.fromARGB(120, 155, 39, 176),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Notes",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Notes Sections
                  _buildSection(
                    message:
                        note1.isEmpty
                            ? "Protect your skin daily with SPF 30+ to prevent wrinkles and sun damage."
                            : note1,
                    cardColor: Colors.orange.shade100.withOpacity(0.7),
                    iconColor: Colors.orange.shade700,
                  ),
                  _buildSection(
                    message:
                        note2.isEmpty
                            ? "Add a serving of greens to your lunch today — rich in vitamins for glowing skin!"
                            : note2,
                    cardColor: Colors.green.shade100.withOpacity(0.7),
                    iconColor: Colors.green.shade700,
                  ),
                  _buildSection(
                    message:
                        note3.isEmpty
                            ? "Take 5 minutes today to breathe deeply or meditate. Stress management = better skin + better mood!"
                            : note3,
                    cardColor: Colors.purple.shade100.withOpacity(0.7),
                    iconColor: Colors.purple.shade700,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Curvednavigator(),
    );
  }

  Widget _buildSection({
    required String message,
    required Color cardColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const SizedBox(width: 10)]),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
