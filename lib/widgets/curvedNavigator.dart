import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/activity_page.dart';
import 'package:demo/home_page.dart';
import 'package:demo/notification_page.dart';
import 'package:demo/supportChatPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

  int _index = 0;
class Curvednavigator extends StatefulWidget{
  const Curvednavigator({super.key});

  @override
  State<Curvednavigator> createState() => _CurvednavigatorState();
}

class _CurvednavigatorState extends State<Curvednavigator> {
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _uploadImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  if (image != null) {
    File file = File(image.path);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? "anonymous";
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child("user_images/$userId/$fileName");
      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();
      print("Image uploaded to Firebase: $imageUrl");

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'profileImageUrl': imageUrl}, SetOptions(merge: true));

        print("✅ Image URL saved to Firestore");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }
}

  @override
  Widget build(context){
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
                Future.delayed(Duration(milliseconds: 250),(){
                if(index == 0){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                }else if(index == 1){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityPage()));
                }else if(index == 2){
                  _uploadImage();
                }else if(index == 3){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                }else if(index == 4){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SupportChatPage()));
                }
                });
               }
    );
  }
}