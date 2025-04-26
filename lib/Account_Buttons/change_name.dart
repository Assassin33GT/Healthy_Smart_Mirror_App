import 'package:demo/buttons/form_container_widget.dart';
import 'package:demo/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeName extends StatefulWidget{
  const ChangeName({super.key});

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {

  TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(context){
    return Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30,),
              Text(
                "Change your name",
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
                    controller: _usernameController,
                    hintText: "New Name",
                  ),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: (){
                    updateUserName(_usernameController.text);
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
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()),(route) => false);
                  },
                  child: Text(
                    "Return Back",
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
  
Future<void> updateUserName(String newName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await user.updateDisplayName(newName);
    await user.reload();  // Refresh user data
    print("User name updated successfully to: ${user.displayName}");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
  } else {
    print("No user is signed in.");
  }
}
}
