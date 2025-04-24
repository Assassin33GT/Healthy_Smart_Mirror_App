import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//List<String> chatIds = [];

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  // Fetch all chat IDs where users have sent messages
  Future<List<String>> fetchUserChatIds() async {
    final chat_idSnapshot = await FirebaseFirestore.instance
        .collection('chats_id') // Collection with all chats
        .get(); // Fetch all chats
    print(chat_idSnapshot.docs);

    if (chat_idSnapshot.docs.isNotEmpty) {
      print("Found chats");
      print(chat_idSnapshot.docs.length);

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
      print(chat_idSnapshot.docs);
      // Loop through each chat document
      for (var chatDoc in chat_idSnapshot.docs) {
        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatIds[i])
            .collection('messages')
            .get();  // Fetch all messages in the chat
        i++;
        // Check if the chat has any messages
        if (messagesSnapshot.docs.isNotEmpty) {
          print("Messages found for chat ${chatDoc.id}");
          
          // Loop through the messages and print the content
          for (var messageDoc in messagesSnapshot.docs) {
            final messageData = messageDoc.data();
            // Assuming 'text' is the field name storing the message content
            print("Message: ${messageData['text']}");  // Replace 'text' if needed
          }

          chatIdsWithMessages.add(chatDoc.id);  // Add chat ID to the list
        } else {
          print("No messages found for chat ${chatDoc.id}");
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
            "Admin Home Page",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        actions: [
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
            itemCount: chatIds.length,
            itemBuilder: (context, index) {
              final chatId = chatIds[index];
              return ListTile(
                title: Text("Chat ID: $chatId"),
                trailing: Icon(Icons.chat_bubble_outline),
                onTap: () {
                  // Optional: Navigate to chat view for this chat ID
                },
              );
            },
          );
        },
      ),
    );
  }
}
