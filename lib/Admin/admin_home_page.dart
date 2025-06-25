import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/Admin/chat_user.dart';
import 'package:demo/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}
    List<String> usersName = [];
class _AdminHomePageState extends State<AdminHomePage> {
  // Fetch all chat IDs where users have sent messages
  Future<List<String>> fetchUserChatIds() async {
    List<String> usersId = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .get();
    print(snapshot.docs);
    for (var doc in snapshot.docs) {;
      usersId.add(doc.id);
    }
    usersName.clear();
    for (String id in usersId) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(id)
          .get();
      
      if (userDoc.exists) {
        String name = userDoc['userName'] ?? 'Unknown User';
        usersName.add(name);
      } else {
        usersName.add('Unknown User');
      }
    }
    
    return usersId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Admin Page",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              ),
            onPressed: () async {
              // Refresh the users
              await fetchUserChatIds(); 
            },
            ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 126, 95, 227),
        toolbarHeight: 70,
      ),
      body: FutureBuilder(
        future: fetchUserChatIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No messages from users yet."));
          }

          final usersId = snapshot.data!;
          
          return ListView.builder(
            itemCount: usersId.length,
            itemBuilder: (context, index) {
              final userId = usersId[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text("user: ${usersName[index]}"),
                  trailing: Icon(Icons.chat_bubble_outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: const Color.fromARGB(85, 126, 95, 227),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatUser(chatId: userId), // Replace with your chat page
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
