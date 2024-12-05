import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../profile/domain/entities/profile_user.dart';
import '../../domain/entities/messenger.dart';
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
    final List<Messenger> _messages = [
      Messenger(
        id: "1",
        senderId: "sender1",
        createOn: DateTime.now(),
        msg: "Hello, how are you?",
        msgDocumentUrl: "docUrl1",
        msgImageUrl: "imgUrl1",
      ),
      Messenger(
        id: "2",
        senderId: "sender2",
        createOn: DateTime.now(),
        msg: "I'm good, thanks!",
        msgDocumentUrl: "docUrl2",
        msgImageUrl: "imgUrl2",
      ),
      Messenger(
        id: "3",
        senderId: "sender1",
        createOn: DateTime.now(),
        msg: "Great to hear!",
        msgDocumentUrl: "docUrl3",
        msgImageUrl: "imgUrl3",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: Column(
        children: [
          //hiển thị tin nhắn
          Container(
            height: 200,
              child: ListView.builder(
                itemCount: _messages.length ,
                itemBuilder: (context, index) {
                  // Lấy một tin nhắn từ danh sách
                  final messenger = _messages[index];
                  final String m =messenger.msg as String;
                  return ListTile(
                    title: Text(m),
                  );
                },
              )),
          //nơi nhập tin nhắn va nut gửi
          TextField(
            decoration: InputDecoration(
              hintText: "Search users..",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
