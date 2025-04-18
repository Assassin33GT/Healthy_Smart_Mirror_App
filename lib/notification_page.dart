import 'package:demo/widgets/curvedNavigator.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget{
  const NotificationPage({super.key});

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
          child: Padding(
            padding: const EdgeInsets.only(top:45.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Notification",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),),
                  ),
                  Divider(color: Colors.white60,),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0, left:8.0),
                    child: Text(
                        "Skin:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                  ),
                  Center(
                    child: Text(
                          "No Data",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),),
                  ),
                  const SizedBox(height: 30,),
                  Divider(color: Colors.black54,),    
                  Padding(
                    padding: const EdgeInsets.only(top:8.0, left:8.0),
                    child: Text(
                        "Meals:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                  ),
                  Center(
                    child: Text(
                          "No Data",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),),
                  ),
                  const SizedBox(height: 30,),
                  Divider(color: Colors.black54,),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0, left:8.0),
                    child: Text(
                        "Tips:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),),
                  ),
                  Center(
                    child: Text(
                          "No Data",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),),
                  ),
                ],
              ),
            ),
          ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }
}