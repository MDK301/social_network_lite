import 'package:flutter/material.dart';

import '../../../profile/domain/entities/profile_user.dart';

class ChatPage extends StatefulWidget {
  final ProfileUser user;
  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dummy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [Expanded(child: ListView(children: [],))],
        ),
      ),
    );
  }
}
