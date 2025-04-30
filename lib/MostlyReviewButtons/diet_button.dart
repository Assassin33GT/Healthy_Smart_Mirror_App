import 'package:demo/buttons/form_container_widget.dart';
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
        await firestore.collection('diet_plans').doc(FirebaseAuth.instance.currentUser!.uid).get();

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
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal Plan")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 126, 95, 227),
              Color.fromARGB(255, 60, 30, 182),
            ],
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
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    //labelText: "Select Diet",
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
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    //labelText: "Select Diet",
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
