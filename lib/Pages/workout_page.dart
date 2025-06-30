import 'package:demo/Pages/exercise_page.dart';
import 'package:demo/main.dart';
import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> exercises = [
      "android/assets/images/exercises/Push-Up.gif",
      "android/assets/images/exercises/Squat.gif",
      "android/assets/images/exercises/Jump-Jack.gif",
      "android/assets/images/exercises/Back-Extensions.gif",
      "android/assets/images/exercises/Plank.gif",
      "android/assets/images/exercises/High-Knees.gif",
      "android/assets/images/exercises/Mountain-Climber.gif",
      "android/assets/images/exercises/Jump-Rope.gif",
      "android/assets/images/exercises/Lunges.gif",
      "android/assets/images/exercises/Squat-Jump.gif",
      "android/assets/images/exercises/Toe-Touches.gif",
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
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
              "Fitness Exercises",
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    exercises.map((exercise) {
                      String ex = exercise.replaceAll(
                        "android/assets/images/exercises/",
                        "",
                      );
                      ex = ex.replaceAll(".gif", "");
                      String description = "";
                      int time = 0;
                      if(ex == 'Push-Up'){
                        description = "Bodyweight exercise that target your chest, shoulders, triceps, and core.";
                        time = 30;
                      }else if(ex == "Squat"){
                        description = "Foundational bodyweight exercise that work your legs, glutes, and core.";
                        time = 30;
                      }else if(ex == "Jump-Jack"){
                        description = "Full-body cardio exercise that improves heart rate, coordination, and warm-up readiness.";
                        time = 1;
                      }else if(ex == "Back-Extensions"){
                        description = "Strengthen the lower back, glutes, and hamstrings.";
                        time = 30;
                      }else if(ex == "Plank"){
                        description = "Isometric core exercise that strengthens your abs, back, shoulders, and glutes.";
                        time = 30;
                      }else if(ex == "High-Knees"){
                        description = "Cardio and lower-body exercise that boosts heart rate, coordination, and leg strength.";
                        time = 1;
                      }else if(ex == "Mountain-Climber"){
                        description = "Dynamic full-body exercise that targets your core, shoulders, arms, and cardiovascular endurance.";
                        time = 30;
                      }else if(ex == "Jump-Rope"){
                        description = "Effective full-body cardio exercise that improves coordination, endurance, and agility.";
                        time = 1;
                      }else if(ex == "Lunges"){
                        description = "Functional lower-body exercise that strengthen the quads, glutes, hamstrings, and improve balance.";
                        time = 1;
                      }else if(ex == "Squat-Jump"){
                        description = "Powerful plyometric (explosive) exercise that build strength in the legs and glutes, while boosting cardio fitness.";
                        time = 30;
                      }else if(ex == "Toe-Touches"){
                        description = "Simple and effective core exercise that primarily target your upper abs, and also engage your hip flexors and lower abs.";
                        time = 1;
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ex,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              exercise,
                              fit: BoxFit.cover,
                              width: 350,
                              height: 250,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  color1 != Colors.black87
                                      ? const Color.fromARGB(255, 178, 86, 194)
                                      : const Color.fromARGB(93, 223, 64, 251),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ExercisePage(
                                        exerciseName: ex,
                                        link: exercise,
                                        description: description,
                                        time: time,
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              "More details",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
