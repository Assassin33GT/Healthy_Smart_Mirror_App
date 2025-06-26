import 'package:demo/main.dart';
import 'package:demo/widgets/curvednavigator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = _auth.currentUser!.uid;
  }

  void updateMessage(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    DocumentSnapshot doc =
        await _firestore
            .collection('chats')
            .doc(user.uid)
            .collection('messages')
            .doc(chatId)
            .get();

    if (doc.exists) {
      if (doc['sender'] != user.displayName && doc['sender'] != 'admin') {
        await _firestore
            .collection('chats')
            .doc(user.uid)
            .collection('messages')
            .doc(chatId)
            .update({'sender': user.displayName});

        await _firestore.collection('chats').doc(user.uid).update({
          'userName': user.displayName,
        });
      }
    }
  }

  void sendMessage(String chatId) async {
    final user = _auth.currentUser;
    final message = _messageController.text.trim();

    if (message.isEmpty || user == null) return;

    await _firestore
        .collection('chats')
        .doc(user.uid)
        .collection('messages')
        .add({
          'text': message,
          'sender': user.displayName ?? 'Anonymous',
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((_) {
          print('Message sent!');
        })
        .catchError((e) {
          print('Error sending message: $e');
        });

    await _firestore.collection('chats').doc(chatId).set({
      'userName': user.displayName ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Support",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            //Divider(color: Colors.white60),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('chats')
                        .doc(chatId)
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
                      final isAdmin = msg['sender'] == 'admin';
                      updateMessage(msg.id);
                      return Align(
                        alignment:
                            isAdmin
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isAdmin
                                    ? const Color.fromARGB(255, 148, 54, 164)
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['sender'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 94, 91, 91),
                                ),
                              ),
                            ],
                          ),
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
                    icon: Icon(
                      Icons.send_outlined,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: () {
                      sendMessage(chatId);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }
}
