import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SkinAnalysisButton extends StatefulWidget {
  const SkinAnalysisButton({super.key});

  @override
  State<SkinAnalysisButton> createState() => _SkinAnalysisButtonState();
}

class _SkinAnalysisButtonState extends State<SkinAnalysisButton> {
  void initState() {
    super.initState();
    getSkinAnalysis(1);
  }

  Future<Map<String, dynamic>?> getSkinAnalysis(int n) async {
    FirebaseAuth user = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore
            .collection("users")
            .doc(user.currentUser!.uid)
            .collection("skin_analysis_history")
            .doc("result$n")
            .get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(context) {
    List<int> numbers = [1, 2, 3, 4, 5];
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Analysis")),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                numbers.map((int value) {
                  return FutureBuilder(
                    future: getSkinAnalysis(value),
                    builder: (context, snapshot) {
                      if (ConnectionState.active == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("${snapshot.hasError}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: const Text(
                            "No Data",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        );
                      }
                      var data = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Results $value:",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Acne Level: ${data['acne_level']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Recommendation: ${data['recommendation']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Skin Condition: ${data['skin_condition']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30,),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
