import 'package:demo/buttons/form_container_widget.dart';
import 'package:demo/home_page.dart';
import 'package:demo/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget{
  const ChangePassword(this.email,{super.key});
  final String email;

  @override
  State<StatefulWidget> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangePassword> {

  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(context){
    return Scaffold(
      body: Container(
        width: double.infinity,
          height: double.infinity,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30,),
              Text(
                "Change your password",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FormContainerWidget(
                    controller: _currentPasswordController,
                    hintText: "Current Password",
                    isPasswordField: true,
                  ),
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FormContainerWidget(
                    controller: _newPasswordController,
                    hintText: "New Password",
                    isPasswordField: true,
                  ),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: (){
                    updateUserPass(_currentPasswordController.text, _newPasswordController.text);
                    //checkUserStatus();
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    )
                  ),
                  const SizedBox(height: 30,),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                  },
                  child: Text(
                    "Return to Login Page",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    )
                  ),
            ],
          ),
      ),
    );
  }
  
  void checkUserStatus() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("⚠️ No user is signed in! Redirecting to login...");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  } else {
    print("✅ User is signed in: ${user.email}");
  }
}

Future<void> updateUserPass(String currentPass, String newPass) async {

  FirebaseAuth.instance.signInWithEmailAndPassword(
    email: widget.email, password: currentPass,
    );
  User? user = FirebaseAuth.instance.currentUser;

    try{
      if (user != null) {
        print("user authenticated");
        // 🔄 Re-authenticate with the entered password
        
        await user.updatePassword(newPass);
        print("✅ Password updated successfully");
      
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
      }else{
        print("⚠️ No user is signed in.");
      }
    }
    catch(e){
      print("Error updating password: $e");
    }
    
  } 
}

