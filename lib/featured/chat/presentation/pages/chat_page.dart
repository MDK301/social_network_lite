import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../profile/domain/entities/profile_user.dart';
import '../component/messenger_buble.dart';

class ChatPage extends StatefulWidget {
  final String myId;
  final String friendId;
  final String friendName;
  final String chatDocId;

  const ChatPage(
      {super.key,
      required this.myId,
      required this.friendId,
      required this.friendName,
      required this.chatDocId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo các listener và xử lý ban đầu
  }
  @override
  void dispose() {
    _messageController.dispose();
    // Hủy bỏ các listener và xử lý dọn dẹp
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: MessengerBubble(messenger: ,isMe:false))
          ],
        ),
      ),
    );
  }
}
