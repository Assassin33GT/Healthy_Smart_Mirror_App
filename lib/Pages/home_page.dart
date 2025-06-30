import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/Account_Buttons/change_name.dart';
import 'package:demo/Account_Buttons/change_password.dart';
import 'package:demo/Account_Buttons/qr_code_page.dart';
import 'package:demo/pages/login_page.dart';
import 'package:demo/main.dart';
import 'package:demo/widgets/curvednavigator.dart';
import 'package:demo/widgets/date_weather.dart';
import 'package:demo/widgets/mostly_review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? email;
  String? _imagePath;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getUsername();
    _loadUserImage();
    saveUserName();
    _loadSavedColors();
    setState(() {
    //increaseCounter();
    });
  }

  void saveUserName() async {
    await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'userName': username,
        });
  }

  void changeBackgroundColor() async{
    setState(() {
      if(color1 == Color.fromARGB(255, 126, 95, 227)){
        color1 = Colors.black87;
      }else{
        color1 = Color.fromARGB(255, 126, 95, 227);
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('color1', color1.toString());
  }

  void getUsername() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      username = user.displayName;
      email = user.email;
    } else {
      print("No user is logged in.");
    }
  }

  Future<void> _loadUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPath = prefs.getString('user_image');
    setState(() {
      _imagePath = savedPath;
      print(_imagePath);
    });
  }

  Future<void> _loadSavedColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedColor1 = prefs.getString('color1');
    setState(() {
      if (savedColor1 == Colors.black87.toString()) {
        color1 = Colors.black87;
      }
    });
  }

  // Profile button
  Widget profileButton() {
    User? user = FirebaseAuth.instance.currentUser;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        iconSize: 20,
        backgroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          sheetAnimationStyle: AnimationStyle(
            curve: Curves.easeInQuad,
            duration: Duration(milliseconds: 340),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 1000,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Divider(color: Colors.white54),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child:
                              _imagePath != null
                                  ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage(
                                      File(_imagePath!),
                                    ),
                                  )
                                  : Icon(
                                    Icons.account_circle_outlined,
                                    size: 70,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle, color: Colors.white),
                    title: Text(
                      "$username",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "$email",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(160, 30),
                            backgroundColor: color1 != Colors.black87? const Color.fromARGB(
                              255,
                              207,
                              69,
                              231,
                            ) : const Color.fromARGB(255, 60, 30, 182),
                          ),
                          onPressed: () {
                            FirebaseAuth.instance.userChanges();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeName(),
                              ),
                            );
                          },
                          child: Text(
                            "Change name",
                            style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(170, 30),
                          backgroundColor: color1 != Colors.black87 ? const Color.fromARGB(
                            255,
                            207,
                            69,
                            231,
                          ) : const Color.fromARGB(255, 60, 30, 182),
                        ),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ChangePassword(user!.email.toString()),
                            ),
                          );
                        },
                        child: Text(
                          "Change password",
                          style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color1 != Colors.black87? const Color.fromARGB(198, 155, 39, 176) : const Color.fromARGB(255, 60, 30, 182),
                        ),
                        onPressed: () {
                          changeBackgroundColor();
                        },
                        child: Icon(color1 == Colors.black87 ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20, color: Colors.white),
                      ),
                      ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color1 != Colors.black87? const Color.fromARGB(198, 155, 39, 176) : const Color.fromARGB(255, 60, 30, 182),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodePage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.qr_code, size: 20, color: Colors.white)
                  ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color1 != Colors.black87 ? Colors.red : const Color.fromARGB(242, 156, 40, 32),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Sign Out",
                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //const SizedBox(height: 20),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color.fromARGB(62, 155, 39, 176),
                  //   ),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => AboutPage()),
                  //     );
                  //   },
                  //   child: Text(
                  //     "About",
                  //     style: TextStyle(fontSize: 13, color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        );
      },
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                _imagePath == null
                    ? Icon(Icons.account_circle_outlined, size: 25)
                    : CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(File(_imagePath!)),
                    ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AnimatedContainer(
        width: double.infinity,
        height: double.infinity,
        duration: const Duration(milliseconds: 2000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color1,
              color2,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding:
              screenWidth > 400
                  ? EdgeInsets.only(left: screenWidth * 0.10)
                  : EdgeInsets.only(left: screenWidth * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(
                        "android/assets/images/smart_mirror.png",
                        width: 60,
                        height: 60,
                        color: Colors.white,
                      ),
                    ),
                    // User Icon
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 25,
                          left: screenWidth * 0.5,
                        ),
                        child: profileButton(),
                      ),
                    ),
                  ],
                ),
              ),
              // Name
              Text(
                "Smart Mirror",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //const SizedBox(height: 20),
              SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Text(
                  "Hi, $username",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Hope you are doing well!",
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
              //const SizedBox(height: 40),
              SizedBox(height: screenHeight * 0.05),
              // Date and Weather
              DateWeather(),
              //const SizedBox(height: 30),
              SizedBox(height: screenHeight * 0.04),
              // Mostly Review
              Text(
                "Mostly Review",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              MostlyReview(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }
}
