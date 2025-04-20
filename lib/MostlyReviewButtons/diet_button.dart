import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// SpoonacularDietPlanner class here (same as in your Dart-only script)
class SpoonacularDietPlanner {
  final String apiKey;
  final String baseUrl = "https://api.spoonacular.com";

  SpoonacularDietPlanner(this.apiKey);

  Future<List<Map<String, dynamic>>> getDietPlan({
    required int calories,
    String? diet,
    List<String>? intolerances,
  }) async {
    List<Map<String, dynamic>> allPlans = [];
    int daysToFetch = 7;

  if(allPlans.isEmpty) {
    for (int week = 0; week < 1; week++) {
      for (int day = 0; day < daysToFetch; day++) {
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
          if (response.statusCode >= 400) return allPlans;
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          allPlans.add(data);
        } catch (_) {
          return allPlans;
        }
      }
    }
  }
    return allPlans;
  }

  Future<Map<String, dynamic>?> getRecipeDetails(int recipeId) async {
    Map<String, String> params = {'apiKey': apiKey};
    var uri = Uri.parse("$baseUrl/recipes/$recipeId/information")
        .replace(queryParameters: params);

    try {
      final response = await http.get(uri);
      if (response.statusCode >= 400) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

// Helper function to format HTML instructions
String formatInstructions(String? rawInstructions) {
  if (rawInstructions == null || rawInstructions.isEmpty) {
    return "No instructions available.";
  }

  String cleaned = rawInstructions
      .replaceAll(RegExp(r"<[^>]+>"), "")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return cleaned;
}

class DietButton extends StatefulWidget {
  const DietButton({super.key});
  @override
  State<DietButton> createState() => _DietButtonState();
}

class _DietButtonState extends State<DietButton> {
  final String apiKey = "29bbc8b420bf4005a12354619047140f";
  late final SpoonacularDietPlanner planner;

  List<Map<String, dynamic>> dietPlans = [];
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    planner = SpoonacularDietPlanner(apiKey);
  }

  Future<void> saveDietPlansToFirestore(List<Map<String, dynamic>> plans) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference dietCollection = firestore.collection('diet_plans');

    for (int i = 0; i < plans.length; i++) {
      final plan = plans[i];
      await dietCollection.add({
        'day': i + 1,
        'timestamp': Timestamp.now(),
        'meals': plan['meals'] ?? [],
        'nutrients': plan['nutrients'] ?? {},
      });
    }
  }

  Future<List<Map<String, dynamic>>> loadPlansFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot snapshot = await firestore.collection('diet_plans').orderBy('day').get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> fetchPlan() async {
    setState(() {
      isLoading = true;
      error = '';
      dietPlans.clear();
    });

    try {
      final existingPlans = await loadPlansFromFirestore();

      if (existingPlans.isNotEmpty) {
        dietPlans = existingPlans;
      } else {
        final result = await planner.getDietPlan(
          calories: 2000,
          diet: "vegetarian",
          intolerances: ["gluten", "dairy"],
        );

        if (result.isEmpty) {
          error = "Failed to fetch data. Check your API key or quota.";
        } else {
          dietPlans = result;
          await saveDietPlansToFirestore(dietPlans);
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
    return Expanded(
      child: ListView.builder(
        itemCount: dietPlans.length,
        itemBuilder: (context, index) {
          final dayPlan = dietPlans[index];
          final meals = dayPlan["meals"] ?? [];
          final nutrients = dayPlan["nutrients"] ?? {};

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📅 Day ${index + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          );
        },
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
            ElevatedButton(
              onPressed: isLoading ? null : fetchPlan,
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
            if (dietPlans.isNotEmpty) buildPlan(),
          ],
        ),
      ),
    );
  }
}
