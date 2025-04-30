import 'package:demo/widgets/curvedNavigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityPage extends StatefulWidget{
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
    Map<String, dynamic>? dietPlan;

    Future<Map<String, dynamic>?> loadPlanFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot snapshot =
        await firestore.collection('diet_plans').doc(FirebaseAuth.instance.currentUser!.email).get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
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

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📅 Today's Meal Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...meals.map<Widget>((meal) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🍲 ${meal['title']}"),
                  Text("⏱️ Ready in: ${meal['readyInMinutes']} mins"),
                  //Text("🔗 ${meal['sourceUrl']}"),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(meal['sourceUrl']);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        throw 'Could not launch ${meal['sourceUrl']}';
                      }
                    },
                    child: Text(
                      "🔗 ${meal['sourceUrl']}",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                ],
              );
            }).toList(),
            const Divider(),
            const Text("📊 Nutrition:"),
            Text("Calories: ${nutrients['calories'] ?? 'N/A'}"),
            Text("Protein: ${nutrients['protein'] ?? 'N/A'}g"),
            Text("Fat: ${nutrients['fat'] ?? 'N/A'}g"),
            Text("Carbs: ${nutrients['carbohydrates'] ?? 'N/A'}g"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(context){
    setState(() {
      fetchSavedPlan();
    });
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.only(top:45.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Activitys",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),),
                  ),
                  Divider(color: Colors.white60,),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0, left:8.0),
                    child: Text(
                        "Skin:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                  ),
                  const SizedBox(height: 20,),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:10.0),
                            child: Card(
                              //margin: const EdgeInsets.only(left:16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "🧴 Anti-Wrinkle Skin Care",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("1. Gentle Cleanser - Protects skin barrier"),
                                    Text("2. Antioxidant Serum (Vitamin C) - Fights free radicals"),
                                    Text("3. Retinol at Night - Boosts collagen"),
                                    Text("4. Rich Moisturizer - Hydrates deeply"),
                                    Text("5. Broad-Spectrum Sunscreen - Prevents UV damage"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Divider(color: Colors.black54,),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0, left:8.0),
                    child: Text(
                        "Meal:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                  ),
                  const SizedBox(height: 20,),
                  Center(
                    child: dietPlan != null
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
                  const SizedBox(height: 30,),
                  Divider(color: Colors.black54,),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0, left:8.0),
                    child: Text(
                        "Tips:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                  ),
                  const SizedBox(height: 20,),
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.only(left:16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "✨Stay Hydrated",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Drink at least 8 glasses of water a day."),
                                  Text("Hydration is key for healthy skin."),
                                  Text("Aim for 7-9 hours of sleep every night."),
                                  Text("Sleep repairs skin and boosts immunity."),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50,),
                ],
              ),
            ),
          ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }
}