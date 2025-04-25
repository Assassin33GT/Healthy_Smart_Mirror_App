import 'package:demo/widgets/curvedNavigator.dart';
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
    });

    final existing = await _firestore
        .collection('chats_id')
        .where('chatId', isEqualTo: chatId)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _firestore.collection('chats_id').add({'chatId': chatId});
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
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
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 45),
                child: Center(
                  child: Text(
                    "Support",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white60),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No messages yet."));
                    }

                    final messages = snapshot.data!.docs;
                    final currentUser = _auth.currentUser;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser =
                            msg['sender'] == currentUser?.displayName;

                        return Align(
                          alignment:
                              isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.purple.shade100
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'],
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['sender'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_outlined, color: Colors.purple),
                      onPressed: () => sendMessage(chatId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }
}
