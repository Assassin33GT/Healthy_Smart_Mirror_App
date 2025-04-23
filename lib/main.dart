import 'package:demo/Admin/admin_home_page.dart';
import 'package:demo/Intro.dart';
import 'package:demo/home_page.dart';
import 'package:demo/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase for web and mobile
  if(kIsWeb == true){
  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyDfnYz0phMnHFHBEiNYKuzY0BjVj1ofAxw",
    authDomain: "flutter-firebase-9420a.firebaseapp.com",
    projectId: "flutter-firebase-9420a",
    storageBucket: "flutter-firebase-9420a.firebasestorage.app",
    messagingSenderId: "773756769859",
    appId: "1:773756769859:web:1e438eb467f5a40b6b26f6"
    ),
  );
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }else{
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Function to choose between LoginPage and HomePage based on user authentication status
    Widget choose(){
      if(user != null){
        if(user.email == "team712347@gmail.com")
        {
          return AdminHomePage();
        }else
        {
          if(user.emailVerified == true){
            return HomePage();
          }
          else{
            return LoginPage();
          }
        }
      }else{
        return LoginPage();
      }
    }
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.purpleAccent,
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Intro(
        choose(),
      ),
    );
  }
}


