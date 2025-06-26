import 'package:demo/Pages/support_chat_page.dart';
import 'package:demo/main.dart';
import 'package:demo/pages/activity_page.dart';
import 'package:demo/pages/home_page.dart';
import 'package:demo/pages/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _index = 0;

class Curvednavigator extends StatefulWidget {
  const Curvednavigator({super.key});
  @override
  State<Curvednavigator> createState() => _CurvednavigatorState();
}

class _CurvednavigatorState extends State<Curvednavigator> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _index = 0;
      });
      // Save image path
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image', image.path);
      print("✅ Image path saved: ${image.path}");
    }
  }

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
      color: color1 != Colors.black87? Color.fromARGB(255, 126, 95, 227) : const Color.fromARGB(140, 88, 30, 182),
      backgroundColor: color1 != Colors.black87? Color.fromARGB(255, 60, 30, 182) : const Color.fromARGB(255, 60, 30, 182),
      buttonBackgroundColor: color1 != Colors.black87? Color.fromARGB(255, 60, 30, 182) : const Color.fromARGB(255, 60, 30, 182),
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
            _openCamera();
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
