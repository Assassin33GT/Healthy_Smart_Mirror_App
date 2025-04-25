import 'package:flutter/material.dart';

class ChatUser extends StatefulWidget{
  final String chatId = "";
  const ChatUser({super.key,required chatId});

  @override
  State<ChatUser> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat User"),
        backgroundColor: const Color.fromARGB(255, 126, 95, 227),
        toolbarHeight: 70,
      ),
      body: Center(
        child: Text("Chat User Page"),
      ),
    );
  }
}