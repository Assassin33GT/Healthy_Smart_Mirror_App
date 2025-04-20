import 'package:demo/buttons/form_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';


TextEditingController calories = TextEditingController();
String selectedDiet = "vegetarian";
List<String> dietOptions = [
  "vegetarian",
  "vegan",
  "paleo",
  "keto",
  "gluten free",
  "whole30",
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

    var uri = Uri.parse("$baseUrl/mealplanner/generate")
        .replace(queryParameters: params);

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
    final CollectionReference dietCollection = firestore.collection('diet_plans');

    await dietCollection.doc("today").set({
      'timestamp': Timestamp.now(),
      'meals': plan['meals'] ?? [],
      'nutrients': plan['nutrients'] ?? {},
    });
  }

  Future<Map<String, dynamic>?> loadPlanFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot snapshot =
        await firestore.collection('diet_plans').doc("today").get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> fetchPlan() async {
    setState(() {
      isLoading = true;
      error = '';
      dietPlan = null;
    });

    try {
      final existingPlan = await loadPlanFromFirestore();

      if (existingPlan != null && flag == 0) {
        dietPlan = existingPlan;
      } else {
        final result = await planner.getDietPlan(
          calories: calories.text.isNotEmpty ? int.parse(calories.text) : 2000,
          diet: selectedDiet,
          intolerances: ["gluten", "dairy"],
        );
        flag = 0;
        if (result == null) {
          error = "Failed to fetch data. Check your API key or quota.";
        } else {
          dietPlan = result;
          await saveDietPlanToFirestore(dietPlan!);
        }
      }
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

    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📅 Today's Meal Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...meals.map<Widget>((meal) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🍲 ${meal['title']}"),
                    Text("⏱️ Ready in: ${meal['readyInMinutes']} mins"),
                    Text("🔗 ${meal['sourceUrl']}"),
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
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Calories input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FormContainerWidget(
                controller: calories,
                hintText: "Enter your calories",
                isPasswordField: false,
                ),
            ),
            const SizedBox(height: 20),
            // Dropdown for diet selection
            Text("Select Diet Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                items: dietOptions.map((String diet) {
                  return DropdownMenuItem<String>(
                    value: diet,
                    child: Text(diet),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDiet = newValue!;
                  });
                }
                ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                if(calories.text.isNotEmpty){
                  fetchPlan();
                  flag = 1;
                }
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Please enter your calories."),
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
              child: const Text("Get Diet Plan"),
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
    );
  }
}
