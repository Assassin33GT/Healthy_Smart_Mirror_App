import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User About"),
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
                // CircleAvatar for User Image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('android/assets/images/person2.jpg'), // New image path for user
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  "Joe Johnson",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Mobile App Designer & Developer",
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
                    "I am a passionate mobile app designer and developer with a strong focus on creating user-friendly and visually appealing apps. I enjoy crafting seamless user experiences and constantly learning new techniques to improve my designs.",
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
                      _buildPersonaInfo("Name", "Sara Johnson"),
                      _buildPersonaInfo("Age", "27"),
                      _buildPersonaInfo("Gender", "Female"),
                      _buildPersonaInfo("Location", "San Francisco, USA"),
                      _buildPersonaInfo("Goals", "Design intuitive and beautiful user interfaces for mobile apps."),
                      _buildPersonaInfo("Pain Points", "Finding the right balance between creativity and usability in app design."),
                      _buildPersonaInfo("Personality", "Creative, detail-oriented, collaborative, proactive."),
                      _buildPersonaInfo("Preferred Platforms", "Android, iOS, Flutter"),
                      _buildPersonaInfo("Typical Day", 
                        "I start my day by checking the latest design trends, followed by working on new UI concepts for ongoing projects. In the afternoon, I participate in team meetings and assist in implementing designs into the app."),
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
                    "Contact Sara",
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
