import 'package:flutter/material.dart';

class AllChatPage extends StatefulWidget {
  final String uid;

  const AllChatPage({super.key, required this.uid});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(child: ListView())
        ],
      ),),
    );
  }
}
