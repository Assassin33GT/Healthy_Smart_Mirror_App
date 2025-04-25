import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatUser extends StatefulWidget {
  final String chatId;
  const ChatUser({super.key, required this.chatId});

  @override
  State<ChatUser> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUser> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async {
    final user = _auth.currentUser;
    final message = _messageController.text.trim();

    if (message.isEmpty || user == null) return;

    print('Sending message from: ${user.uid}');

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'text': message,
          'sender': 'admin',
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((_) {
          print('Message sent!');
        })
        .catchError((e) {
          print('Error sending message: $e');
        });

    // Check if chatId already exists in chats_id collection
    final existing = await _firestore
        .collection('chats_id')
        .where('chatId', isEqualTo: widget.chatId)
        .limit(1)
        .get();

    // Only add if it doesn't already exist
    if (existing.docs.isEmpty) {
      await _firestore.collection('chats_id').add({'chatId': widget.chatId});
      print('chatId saved to chats_id.');
    } else {
      print('chatId already exists. Not saving duplicate.');
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat User",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 126, 95, 227),
        toolbarHeight: 70,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Divider(color: Colors.white60),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No messages yet."));
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return ListTile(
                          title: Text(
                            msg['text'],
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            msg['sender'],
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Enter message...",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send_outlined, color: Colors.purple),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
