import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  const IntroPage(this.child, {super.key});
  final Widget? child;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Future<void> _loadSavedColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedColor1 = prefs.getString('color1');
    setState(() {
      if (savedColor1 == Colors.black87.toString()) {
        color1 = Colors.black87;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedColors();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => widget.child!),
        (route) => false,
      );
    });
    
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: AnimatedContainer(
        width: double.infinity,
        height: double.infinity,
        duration: Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1,color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Image.asset(
            "android/assets/images/Intro.gif",
            color: const Color.fromARGB(197, 221, 172, 24),
            width: 50,
            height: 50,
          ),
        ),
      ),
    );
  }
}
