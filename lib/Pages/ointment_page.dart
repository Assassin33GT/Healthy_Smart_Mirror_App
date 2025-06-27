import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OintmentPage extends StatefulWidget {
  const OintmentPage({super.key});

  @override
  State<OintmentPage> createState() => _OintmentPageState();
}

class _OintmentPageState extends State<OintmentPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cardAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return data;
  }

  @override
  Widget build(context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1 != Colors.black87 ? color1 : const Color.fromARGB(255, 85, 22, 96), color2],
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
              "Ointment",
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
          child: FutureBuilder(
            future: getSkinTips(),
            builder: (context, snapshot) {
              if (ConnectionState.active == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const Center(
                  child: Text(
                    "No Data",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              Map<String, dynamic> allData = snapshot.data!;
              Map<String, dynamic> data = allData['cosmetic'];
              String recommendation = allData['recommendation'];
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Ointment Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildOintmentSection(
                      icon: Icons.business,
                      title: "Brand",
                      value: data['brand'],
                      cardColor: Colors.purple.shade100.withOpacity(0.7),
                      iconColor: Colors.purple.shade700,
                    ),
                    _buildOintmentSection(
                      icon: Icons.label_important,
                      title: "Name",
                      value: data['name'],
                      cardColor: Colors.blue.shade100.withOpacity(0.7),
                      iconColor: Colors.blue.shade700,
                    ),
                    _buildOintmentSection(
                      icon: Icons.category,
                      title: "Category",
                      value: data['categories'],
                      cardColor: Colors.green.shade100.withOpacity(0.7),
                      iconColor: Colors.green.shade700,
                    ),
                    _buildOintmentSection(
                      icon: Icons.warning_amber_rounded,
                      title: "Constraints",
                      value: data['constraints'],
                      cardColor: Colors.orange.shade100.withOpacity(0.7),
                      iconColor: Colors.orange.shade700,
                    ),
                    _buildOintmentSection(
                      icon: Icons.science,
                      title: "Ingredients",
                      value: data['ingredients'],
                      cardColor: Colors.pink.shade100.withOpacity(0.7),
                      iconColor: Colors.pink.shade700,
                    ),
                    _buildOintmentSection(
                      icon: Icons.recommend,
                      title: "Recommendation",
                      value: recommendation,
                      cardColor: Colors.yellow.shade100.withOpacity(0.7),
                      iconColor: Colors.yellow.shade700,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOintmentSection({
    required IconData icon,
    required String title,
    required String value,
    required Color cardColor,
    required Color iconColor,
  }) {
    print(_cardAnimation);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
