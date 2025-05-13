import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/Admin/chat_user.dart';
import 'package:demo/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<String> names = [];

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Fetch all chat IDs where users have sent messages
  Future<List<String>> fetchUserChatIds() async {
    final chat_idSnapshot = await FirebaseFirestore.instance
        .collection('chats_id') // Collection with all chats
        .get(); // Fetch all chats
    //print(chat_idSnapshot.docs);
    names = [];
 
    if (chat_idSnapshot.docs.isNotEmpty) {

      List<String> chatIds = [];
      for(var chatDoc in chat_idSnapshot.docs){
        final chatId = chatDoc.data()['chatId'] as String?; // Get chat ID
        if (chatId != null) {
          chatIds.add(chatId); // Add to list of chat IDs
        }
        print(chatId);
      }

      List<String> chatIdsWithMessages = [];

      int i = 0;
      
      // Loop through each chat document
      for (var chatDoc in chat_idSnapshot.docs) {
        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatIds[i])
            .collection('messages')
            .get();  // Fetch all messages in the chat
        i++;
        //print(chat_idSnapshot.docs);
        for(int j = 0;j<messagesSnapshot.docs.length;j++){
          if(messagesSnapshot.docs[j]['sender'] != 'admin')
            {
              names.add(messagesSnapshot.docs[j]['sender']);
              break;
            }
        }
        
        // Check if the chat has any messages
        if (messagesSnapshot.docs.isNotEmpty) {
          print("Messages found for chat ${chatDoc['chatId']}");
          
          // Loop through the messages and print the content
          // for (var messageDoc in messagesSnapshot.docs) {
          //   final messageData = messageDoc.data();
          //   print("Message: ${messageData['text']}");  // Replace 'text' if needed
          // }

          chatIdsWithMessages.add(chatDoc['chatId']);  // Add chat ID to the list
        } else {
          print("No messages found for chat ${chatDoc['chatId']}");
        }
      }

      return chatIdsWithMessages;  // Return all chat IDs that have messages
    } else {
      print("No chats found");
      return [];
    }
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
      body: FutureBuilder<List<String>>(
        future: fetchUserChatIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No messages from users yet."));
          }

          final chatIds = snapshot.data!;
          
          return ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              final chatId = chatIds[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text("user: ${names[index]}"),
                  trailing: Icon(Icons.chat_bubble_outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: const Color.fromARGB(85, 126, 95, 227),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatUser(chatId: chatId), // Replace with your chat page
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
