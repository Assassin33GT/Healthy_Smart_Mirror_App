//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/activity_page.dart';
import 'package:demo/home_page.dart';
import 'package:demo/notification_page.dart';
import 'package:demo/qr_code_page.dart';
import 'package:demo/qr_scanner.dart';
import 'package:demo/supportChatPage.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

int _index = 0;
  
class Curvednavigator extends StatefulWidget {
  const Curvednavigator({
    super.key,
    });
  @override
  State<Curvednavigator> createState() => _CurvednavigatorState();
}

class _CurvednavigatorState extends State<Curvednavigator> {
  // final ImagePicker _picker = ImagePicker();

  // Future<void> _openCamera() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  //   if (image != null) {
  //     setState(() {
  //       _index = 0;
  //       print(image.path);
  //     });
  //     // Save image path
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('user_image', image.path);
  //     print("✅ Image path saved: ${image.path}");
  //   }
  // }

  @override
  Widget build(context) {
    final items = <Widget>[
      Icon(Icons.home_outlined),
      Icon(Icons.workspace_premium),
      Icon(Icons.camera_alt_outlined),
      Icon(Icons.notifications_active_outlined),
      Icon(Icons.support_agent_outlined),
    ];

    return CurvedNavigationBar(
      height: 60,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 250),
      color: Color.fromARGB(255, 126, 95, 227),
      backgroundColor: Color.fromARGB(255, 60, 30, 182),
      buttonBackgroundColor: Color.fromARGB(255, 60, 30, 182),
      items: items,
      index: _index,
      onTap: (index) {
        setState(() {
          _index = index;
        });
        // Handle button tap
        Future.delayed(Duration(milliseconds: 250), () {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityPage()),
            );
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => QRCodePage()),
              (route) => false,
            );
            //_openCamera();
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportChatPage()),
            );
          }
        });
      },
    );
  }
}
