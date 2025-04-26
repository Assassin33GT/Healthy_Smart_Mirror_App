import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin About"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        elevation: 4.0,
      ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // CircleAvatar for Admin Image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/admin.jpg'), // Make sure this path is correct
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 20),
                Text(
                  "Admin Name",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Admin Role & Manager",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "I am the admin responsible for overseeing the project, ensuring things run smoothly, and supporting the development team. My goal is to help facilitate the best possible user experience through collaboration.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonaInfo("Name", "Admin Name"),
                      _buildPersonaInfo("Age", "35"),
                      _buildPersonaInfo("Gender", "Male"),
                      _buildPersonaInfo("Location", "City, Country"),
                      _buildPersonaInfo("Goals", "Oversee project management and ensure smooth collaboration."),
                      _buildPersonaInfo("Pain Points", "Struggles with balancing multiple teams and priorities."),
                      _buildPersonaInfo("Personality", "Organized, decisive, collaborative, supportive."),
                      _buildPersonaInfo("Preferred Platforms", "Web, iOS, Android"),
                      _buildPersonaInfo("Typical Day", 
                        "Start the day with team meetings, review the progress of ongoing tasks, troubleshoot any issues with the team, and strategize for the next phase of the project."),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Add your action here, like navigating to a contact page
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 162, 21, 187),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 50.0),
                  ),
                  child: Text(
                    "Contact Admin",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build persona info
  Widget _buildPersonaInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
    );
  }
}