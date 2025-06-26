import 'package:demo/Pages/ointment_page.dart';
import 'package:demo/main.dart';
import 'package:demo/widgets/curvednavigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  Map<String, dynamic>? dietPlan;

  @override
  void initState() {
    super.initState();
    getSkinTips();
  }

  Future<Map<String, dynamic>?> loadPlanFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot snapshot =
        await firestore
            .collection('diet_plans')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>> getSkinTips() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("skin_analysis_history")
        .doc("result5")
        .get(GetOptions(source: Source.server));

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    data = data['cosmetic'] as Map<String, dynamic>;
    return data;
  }

  Future<int> fetchSavedPlan() async {
    final existingPlan = await loadPlanFromFirestore();
    try {
      if (existingPlan != null) {
        setState(() {
          dietPlan = existingPlan;
        });
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      print("Error loading plan from Firestore: $e");
      return 0;
    }
  }

  Widget buildPlan() {
    fetchSavedPlan();
    final meals = dietPlan?["meals"] ?? [];
    final nutrients = dietPlan?["nutrients"] ?? {};

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      //margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(178, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color1, Colors.purple.shade500],
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Today's Meal Plan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...meals.asMap().entries.map((entry) {
                    final meal = entry.value;
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 500),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20.0 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Card(
                              color: const Color.fromARGB(150, 255, 255, 255),
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.restaurant,
                                          color: Colors.purple.shade300,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            meal['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${meal['readyInMinutes']} mins",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                          meal['sourceUrl'],
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.link,
                                            size: 16,
                                            color: Colors.blue.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "View Recipe",
                                            style: TextStyle(
                                              color: Colors.blue.shade400,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  const Divider(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(150, 255, 255, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.monitor_heart, color: Colors.purple),
                            SizedBox(width: 8),
                            Text(
                              "Nutrition Summary",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildNutrientRow(
                          "Calories",
                          "${nutrients['calories'] ?? 'N/A'}",
                          Icons.local_fire_department,
                        ),
                        _buildNutrientRow(
                          "Protein",
                          "${nutrients['protein'] ?? 'N/A'}g",
                          Icons.fitness_center,
                        ),
                        _buildNutrientRow(
                          "Fat",
                          "${nutrients['fat'] ?? 'N/A'}g",
                          Icons.water_drop,
                        ),
                        _buildNutrientRow(
                          "Carbs",
                          "${nutrients['carbohydrates'] ?? 'N/A'}g",
                          Icons.grain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple.shade300),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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

  Future<Widget> buildSkinCareStep(int n) async {
    Map<String, dynamic>? data = await getSkinAnalysis(n);
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20.0 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              color: const Color.fromARGB(150, 255, 255, 255),
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        "$n",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.purple.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Acne: ${(data!['Acne'] * 100).toInt()}%, Eczema: ${(data['Eczema'] * 100).toInt()}%, Healthy: ${(data['Healthy'] * 100).toInt()}%, Pigmentation: ${(data['Pigmentation'] * 100).toInt()}%, Rosacea: ${(data['Rosacea'] * 100).toInt()}%, Wrinkles: ${(data['Wrinkles'] * 100).toInt()}%",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data['recommendation'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FutureBuilder getSavedSkinAnalysis(int n) {
    return FutureBuilder(
      future: buildSkinCareStep(n),
      builder: (context, snapshot) {
        if (ConnectionState.active == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (!snapshot.hasData) {
          return Center(child: Text("No Data"));
        }
        return snapshot.data!;
      },
    );
  }

  @override
  Widget build(context) {
    setState(() {
      fetchSavedPlan();
    });
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Activitys",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    letterSpacing: 1.2,
                  ),
                ),
                //Divider(color: Colors.white60),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(178, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          color1,
                                          Colors.purple.shade500,
                                        ],
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.spa, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          "Skin Analysis Results",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        getSavedSkinAnalysis(1),
                                        getSavedSkinAnalysis(2),
                                        getSavedSkinAnalysis(3),
                                        getSavedSkinAnalysis(4),
                                        getSavedSkinAnalysis(5),
                                      ],
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
                const SizedBox(height: 30),
                Divider(color: Colors.black54),
                const SizedBox(height: 20),
                Center(
                  child:
                      dietPlan != null
                          ? buildPlan()
                          : const Text(
                            "No Data",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                ),
                const SizedBox(height: 30),
                Divider(color: Colors.black54),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          //margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(178, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [color1, Colors.purple.shade500],
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Health Tips",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    _buildHealthTip(
                                      "Stay Hydrated",
                                      "Drink at least 8 glasses of water a day",
                                      Icons.water,
                                    ),
                                    FutureBuilder(
                                      future: getSkinTips(),
                                      builder: (context, snapshot) {
                                        if (ConnectionState.active ==
                                            ConnectionState.waiting) {
                                          return _buildHealthTip(
                                            "Loading...",
                                            "Loading...",
                                            Icons.face,
                                          );
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.hasError) {
                                          return _buildHealthTip(
                                            "Skin Health",
                                            "Hydration is key for healthy skin",
                                            Icons.face,
                                          );
                                        }
                                        Map<String, dynamic> data =
                                            snapshot.data!;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => OintmentPage(),
                                              ),
                                            );
                                          },
                                          child: _buildHealthTip(
                                            "${data['name']}",
                                            "${data['brand']} : Click for more details!",
                                            Icons.face,
                                          ),
                                        );
                                      },
                                    ),
                                    _buildHealthTip(
                                      "Sleep Well",
                                      "Aim for 7-9 hours of sleep every night",
                                      Icons.bedtime,
                                    ),
                                    _buildHealthTip(
                                      "Skin Repair",
                                      "Sleep repairs skin and boosts immunity",
                                      Icons.healing,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }

  Widget _buildHealthTip(String title, String description, IconData icon) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20.0 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 3,
              ),
              child: Card(
                color: const Color.fromARGB(150, 255, 255, 255),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.purple.shade300),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
