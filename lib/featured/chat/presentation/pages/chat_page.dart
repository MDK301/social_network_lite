import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../data/firebase_chat_repo.dart';
import '../../domain/entities/messenger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;

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
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _messageController = TextEditingController();

  //GUI TIN NHAN( NAY CHI LA BO LOC)
  void onSendMessage(String content, String type, [String? imageUrl]) async {
    if (_message.text.isNotEmpty || type == 'image') {
      // Messenger message = Messenger(
      //   id: '',
      //   senderId: widget.myId,
      //   msg: _message.text,
      //   createOn: DateTime.now(),
      // );
      //
      // final firebaseChatRepo =
      //     FirebaseChatRepo(); // Hoặc truy cập instance hiện có
      // firebaseChatRepo.sendMessenger(widget.chatDocId, message);
      // _message.clear();

      _sendTextMessage(content, type, imageUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tin nhắn rỗng, vui lòng nhập vào.'),
        ),
      );
      print("enter Text");
    }
  }

  //GUI TIN NHAN
  void _sendTextMessage(String content, String type, [String? imageUrl]) {
    // ... (phần còn lại của hàm _sendTextMessage)
    Messenger message = Messenger(
        id: '',
        senderId: widget.myId,
        msg: _message.text,
        msgImageUrl: imageUrl,
        createOn: DateTime.now());

    final firebaseChatRepo =
        FirebaseChatRepo(); // Hoặc truy cập instance hiện có
    firebaseChatRepo.sendMessenger(widget.chatDocId, message);
    _message.clear();
  }

  //CHON ANH DE TAI LEN
  Future<void> _chonAnh() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Tải ảnh lên Firebase Storage (xem bước 4)
      String imageUrl = await _taiAnhLen(pickedImage.path);

      // Gửi tin nhắn với URL ảnh
      onSendMessage(_messageController.text, 'image', imageUrl);
      _messageController.clear();
    }
  }

  //TAI ANH LEN KHI CHON ANH
  Future<String> _taiAnhLen(String imagePath) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageReference.putFile(File(imagePath));
    await uploadTask.whenComplete(() {});

    final String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  }

  //TAI ANH XUONG =))) xuong lam gi roi lai phai len~


  Future<void> _luuAnh(String imageUrl) async {
    var response =await http.get(Uri.parse(imageUrl));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 80,
        name: "image");
    print(result);
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
                    IconButton(
                      onPressed: _chonAnh,
                      icon: Icon(Icons.image),
                    ),
                    Flexible(
                      // height: size.height / 15,
                      // width: size.width / 1.3,
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
                      onPressed: () =>
                          onSendMessage(_messageController.text, 'text'),
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
            color: map["senderId"] != widget.myId
                ? Theme.of(context).colorScheme.inversePrimary
                : Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            children: [
              (map["msg"] != null || map["msgImageUrl"] != null)
                  ? Column(
                      children: [

                        //Nếu hình ảnh ton tại
                        (map["msgImageUrl"] != null)
                            ? GestureDetector(
                          onTap: (){_luuAnh(map["msgImageUrl"]);},
                            child: CachedNetworkImage(imageUrl: map["msgImageUrl"]))
                            : const SizedBox(),

                        //Nếu tin nhan ton tai
                        (map["msg"] != null)
                            ? Text(
                                map["msg"],
                                //STYLE OF MSG
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: map["senderId"] != widget.myId
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )
                  : const Text('Loading...'),
            ],
          )),
    );
  }
}
