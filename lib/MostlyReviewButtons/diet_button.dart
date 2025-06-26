import 'package:demo/Widgets/form_container_widget.dart';
import 'package:demo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

TextEditingController calories = TextEditingController();
String selectedDiet = "Vegetarian";
List<String> dietOptions = [
  "Gluten Free",
  "Ketogenic",
  "Vegetarian",
  "Lacto-Vegetarian",
  "Ovo-Vegetarian",
  "Vegan",
  "Pescetarian",
  "Paleo",
  "Primal",
  "Low FODMAP",
  "Whole30",
];
String selectedIntolerance = "None";
List<String> selectedIntolerances = [];
List<String> intoleranceOptions = [
  "Dairy",
  "Egg",
  "paleo",
  "Gluten",
  "Grain",
  "Peanut",
  "Seafood",
  "Sesame",
  "Shellfish",
  "Soy",
  "Sulfite",
  "Tree Nut",
  "Wheat",
  "None",
];
int flag = 0;

class SpoonacularDietPlanner {
  final String apiKey = "29bbc8b420bf4005a12354619047140f";
  final String baseUrl = "https://api.spoonacular.com";

  SpoonacularDietPlanner();

  Future<Map<String, dynamic>?> getDietPlan({
    required int calories,
    String? diet,
    List<String>? intolerances,
  }) async {
    Map<String, String> params = {
      'apiKey': apiKey,
      'targetCalories': calories.toString(),
      'timeFrame': 'day',
    };

    if (diet != null) params['diet'] = diet;
    if (intolerances != null && intolerances.isNotEmpty) {
      params['intolerances'] = intolerances.join(',');
    }

    var uri = Uri.parse(
      "$baseUrl/mealplanner/generate",
    ).replace(queryParameters: params);

    try {
      final response = await http.get(uri);
      if (response.statusCode >= 400) {
        print("Error: ${response.statusCode}");
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}

class DietButton extends StatefulWidget {
  const DietButton({super.key});

  @override
  State<DietButton> createState() => _DietButtonState();
}

class _DietButtonState extends State<DietButton> {
  late final SpoonacularDietPlanner planner;

  Map<String, dynamic>? dietPlan;
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    planner = SpoonacularDietPlanner();
  }

  Future<void> saveDietPlanToFirestore(Map<String, dynamic> plan) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference dietCollection = firestore.collection(
      'diet_plans',
    );

    await dietCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
      'timestamp': Timestamp.now(),
      'meals': plan['meals'] ?? [],
      'nutrients': plan['nutrients'] ?? {},
    });
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

  Future<void> fetchPlan() async {
    setState(() {
      isLoading = true;
      error = '';
      dietPlan = null;
    });

    try {
      final result = await planner.getDietPlan(
        calories: calories.text.isNotEmpty ? int.parse(calories.text) : 2000,
        diet: selectedDiet,
        intolerances:
            selectedIntolerances.isEmpty ? null : selectedIntolerances,
      );

      if (result == null) {
        error = "Failed to fetch data. Check your API key or quota.";
      } else {
        dietPlan = result;
        await saveDietPlanToFirestore(dietPlan!);
      }
      // }
    } catch (e) {
      error = "An error occurred: $e";
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildPlan() {
    fetchSavedPlan();
    final meals = dietPlan?["meals"] ?? [];
    final nutrients = dietPlan?["nutrients"] ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        //margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              color1 != Colors.black87
                  ? const Color.fromARGB(178, 255, 255, 255)
                  : const Color.fromARGB(105, 255, 255, 255),
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
                      color1 != Colors.black87
                          ? color1
                          : const Color.fromARGB(255, 60, 30, 182),
                      Colors.purple.shade500,
                    ],
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
                                color:
                                    color1 != Colors.black87
                                        ? const Color.fromARGB(
                                          150,
                                          255,
                                          255,
                                          255,
                                        )
                                        : const Color.fromARGB(
                                          107,
                                          255,
                                          255,
                                          255,
                                        ),
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  LaunchMode
                                                      .externalApplication,
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
                        color:
                            color1 != Colors.black87
                                ? const Color.fromARGB(150, 255, 255, 255)
                                : const Color.fromARGB(173, 197, 196, 196),
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

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color1 != Colors.black87
                    ? color1
                    : const Color.fromARGB(255, 85, 22, 96),
                color2,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              "Diet Plans",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Calories input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FormContainerWidget(
                  controller: calories,
                  hintText: "Enter the amount of calories",
                  isPasswordField: false,
                ),
              ),
              const SizedBox(height: 20),
              // Dropdown for diet selection
              Text(
                "Select Diet Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(121, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: selectedDiet,
                  menuMaxHeight: 300,
                  items:
                      dietOptions.map((String diet) {
                        return DropdownMenuItem<String>(
                          value: diet,
                          child: Text(diet),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDiet = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Dropdown for Intolerance
              Text(
                "Select Intolerance Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(121, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: selectedIntolerance,
                  menuMaxHeight: 300,
                  items:
                      intoleranceOptions.map((String intolerance) {
                        return DropdownMenuItem<String>(
                          value: intolerance,
                          child: Text(intolerance),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIntolerance = newValue!;
                    });
                  },
                ),
              ),
              // print intolerances
              if (flag == 0)
                ...selectedIntolerances.map((String intolerance) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: ListTile(
                        title: Text(intolerance),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedIntolerances.remove(intolerance);
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 10),
              // Button to add Intolerance
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    int i;
                    flag = 0;
                    for (i = 0; i < selectedIntolerances.length; i++) {
                      print(selectedIntolerances.length);
                      if (selectedIntolerances[i] == selectedIntolerance) {
                        break;
                      }
                    }
                    if (i == selectedIntolerances.length &&
                        selectedIntolerance != "None") {
                      selectedIntolerances.add(selectedIntolerance);
                    }

                    print(selectedIntolerances);
                  });
                },
                child: const Text(
                  "Add Intolerance",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Get saved diet plan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () async {
                      int result = await fetchSavedPlan();
                      if (result == 1) {
                        flag = 1;
                        fetchSavedPlan();
                      } else if (result == 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content: const Text("No diet plan found."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Show Saved Diet Plan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Get new diet plan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 162, 21, 187),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () {
                      if (calories.text.isNotEmpty) {
                        flag = 1;
                        fetchPlan();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content: const Text(
                                "Please enter your calories.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Get New Diet Plan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              if (dietPlan != null) buildPlan(),
            ],
          ),
        ),
      ),
    );
  }
}
