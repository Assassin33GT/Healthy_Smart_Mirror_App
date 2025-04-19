import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    saveDietsPlans();
  }

  Future<void> saveDietsPlans() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('diet_plans', dietPlans.map((plan) => jsonEncode(plan)).toList());
  }

  Future<void> loadDietPlans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List? savedPath = prefs.getStringList('diet_plans');
  
    setState(() {
      //dietPlans = savedPath;
      print(dietPlans);
    });
  }

  Future<void> fetchPlan() async {
    setState(() {
      isLoading = true;
      error = '';
      dietPlans.clear();
    });

    // user inputs
    try {
      final result = await planner.getDietPlan(
        calories: 2000,
        diet: "vegetarian",
        intolerances: ["gluten", "dairy"],
      );

      if (result.isEmpty) {
        error = "Failed to fetch data. Check your API key or quota.";
      } else {
        dietPlans = result;
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
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📅 Day ${index + 1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...meals.map<Widget>((meal) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🍲 ${meal['title']}"),
                        Text("⏱️ Ready in: ${meal['readyInMinutes']} mins"),
                        Text("🔗 ${meal['sourceUrl']}"),
                        SizedBox(height: 6),
                      ],
                    );
                  }).toList(),
                  Divider(),
                  Text("📊 Nutrition:"),
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
      appBar: AppBar(title: Text("Meal Plan")),
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
