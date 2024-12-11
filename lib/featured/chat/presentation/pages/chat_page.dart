import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/firebase_chat_repo.dart';
import '../../domain/entities/messenger.dart';

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
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _messageController = TextEditingController();

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Messenger message = Messenger(
        id: '',
        senderId: widget.myId,
        msg: _message.text,
        createOn: DateTime.now(),
      );

      final firebaseChatRepo =
          FirebaseChatRepo(); // Hoặc truy cập instance hiện có
      firebaseChatRepo.sendMessenger(widget.chatDocId, message);
      _message.clear();
    } else {
      print("enter Text");
    }
  }

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //hiển thị tin nhắn
            Container(
                height: size.height / 1.25,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .doc(widget.chatDocId)
                        .collection('messenger')
                        .orderBy("createOn", descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          // Lấy một tin nhắn từ danh sách
                          Map<String, dynamic>? map = snapshot.data?.docs[index]
                              .data() as Map<String, dynamic>?;
                          if (map != null) {
                            return messages(size, map);
                          } else {
                            return CircularProgressIndicator(); // Or any other loading indicator
                          }
                        },
                      );
                    })),
            //nơi nhập tin nhắn va nut gửi
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        maxLines: null, //cho phep xuong dong
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "type messenger..",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onSendMessage,
                      icon: Icon(Icons.send),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map["senderId"] != widget.myId
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color:
          map["senderId"] != widget.myId
        ? Theme.of(context).colorScheme.inversePrimary
          : Theme.of(context).colorScheme.primary,
        ),
        child: Column(children: [
          (map["msg"] != null)
              ? Text(
            map["msg"]
            // map['sendBy']
            ,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: map["senderId"] != widget.myId
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.inversePrimary,
            ),
          )
              : const Text('Loading...'),
        ],)


      ),
    );
  }
}
