import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../data/firebase_chat_repo.dart';
import '../../domain/entities/messenger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// class ChatPage extends StatefulWidget {
//   final String myId;
//   final String friendId;
//   final String friendName;
//   final String chatDocId;
//
//   const ChatPage(
//       {super.key,
//       required this.myId,
//       required this.friendId,
//       required this.friendName,
//       required this.chatDocId});
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final TextEditingController _messageController = TextEditingController();
//
//   //GUI TIN NHAN( NAY CHI LA BO LOC)
//   void onSendMessage(String content, String type, [String? imageUrl]) async {
//     if (_message.text.isNotEmpty || type == 'image') {
//       // Messenger message = Messenger(
//       //   id: '',
//       //   senderId: widget.myId,
//       //   msg: _message.text,
//       //   createOn: DateTime.now(),
//       // );
//       //
//       // final firebaseChatRepo =
//       //     FirebaseChatRepo(); // hoặc truy cập instance hiện có
//       // firebaseChatRepo.sendMessenger(widget.chatDocId, message);
//       // _message.clear();
//
//       _sendTextMessage(content, type, imageUrl);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Tin nhắn rỗng, vui lòng nhập vào.'),
//         ),
//       );
//       print("enter Text");
//     }
//   }
//
//   //GUI TIN NHAN
//   void _sendTextMessage(String content, String type, [String? imageUrl]) {
//     // ... (phần còn lại của hàm _sendTextMessage)
//     Messenger message = Messenger(
//         id: '',
//         senderId: widget.myId,
//         msg: _message.text,
//         msgImageUrl: imageUrl,
//         createOn: DateTime.now());
//
//     final firebaseChatRepo =
//         FirebaseChatRepo(); // Hoặc truy cập instance hiện có
//     firebaseChatRepo.sendMessenger(widget.chatDocId, message);
//     _message.clear();
//   }
//
//   //CHON ANH DE TAI LEN
//   Future<void> _chonAnh() async {
//     final XFile? pickedImage =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       // T=tải ảnh lên Firebase Storage .-.
//       String imageUrl = await _taiAnhLen(pickedImage.path);
//
//       // gửi tin nhắn với URL ảnh
//       onSendMessage(_messageController.text, 'image', imageUrl);
//       _messageController.clear();
//     }
//   }
//
//   //TAI ANH LEN KHI CHON ANH
//   Future<String> _taiAnhLen(String imagePath) async {
//     final Reference storageReference = FirebaseStorage.instance
//         .ref()
//         .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
//
//     final UploadTask uploadTask = storageReference.putFile(File(imagePath));
//     await uploadTask.whenComplete(() {});
//
//     final String downloadUrl = await storageReference.getDownloadURL();
//     return downloadUrl;
//   }
//
//   //TAI ANH XUONG =))) xuong lam gi roi lai phai len~
//   Future<void> _luuAnh(String imageUrl) async {}
//
//   void addNewPersonIntoChat() {
//     final TextEditingController searchController = TextEditingController();
//     final ValueNotifier<List<Map<String, dynamic>>> searchResultsNotifier = ValueNotifier([]);
//     final ValueNotifier<List<Map<String, dynamic>>> selectedUsersNotifier = ValueNotifier([]);
//
//     void searchUsers(String query) async {
//       final lowercaseQuery = query.toLowerCase();
//
//       if (query.isNotEmpty) {
//         final result = await FirebaseFirestore.instance.collection("users").get();
//
//         final filteredUsers = result.docs.where((doc) {
//           final lowercaseName = doc.data()['name'].toString().toLowerCase();
//           return lowercaseName.startsWith(lowercaseQuery);
//         }).toList();
//
//         searchResultsNotifier.value = filteredUsers
//             .map((doc) => {
//           'id': doc.id,
//           ...doc.data(),
//         })
//             .toList();
//       } else {
//         searchResultsNotifier.value = [];
//       }
//     }
//
//     void addUserToSelected(Map<String, dynamic> user) {
//       if (!selectedUsersNotifier.value.any((u) => u['id'] == user['id'])) {
//         selectedUsersNotifier.value = [...selectedUsersNotifier.value, user];
//       }
//     }
//
//     void removeUserFromSelected(String userId) {
//       selectedUsersNotifier.value = selectedUsersNotifier.value.where((u) => u['id'] != userId).toList();
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: SizedBox(
//           width: 400,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // TextField để nhập từ khóa tìm kiếm
//               TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search users...",
//                   hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                 ),
//                 onChanged: (value) => searchUsers(value),
//               ),
//               const SizedBox(height: 10),
//
//               // Khung hiển thị kết quả tìm kiếm
//               Container(
//                 height: 170,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ValueListenableBuilder<List<Map<String, dynamic>>>(
//                   valueListenable: searchResultsNotifier,
//                   builder: (context, searchResults, _) {
//                     if (searchResults.isNotEmpty) {
//                       return ListView.builder(
//                         itemCount: searchResults.length,
//                         itemBuilder: (context, index) {
//                           final user = searchResults[index];
//                           return ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: NetworkImage(user['profileImageUrl'] ?? ''),
//                               child: user['profileImageUrl'] == null
//                                   ? const Icon(Icons.person)
//                                   : null,
//                             ),
//                             title: Text(user['name'] ?? 'Unknown'),
//                             subtitle: Text(user['email'] ?? ''),
//                             onTap: () => addUserToSelected(user),
//                           );
//                         },
//                       );
//                     } else {
//                       return const Center(
//                         child: Text(
//                           "No users found",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//               const SizedBox(height: 10),
//
//               // Khung hiển thị người dùng đã chọn
//               Container(
//                 height: 170,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ValueListenableBuilder<List<Map<String, dynamic>>>(
//                   valueListenable: selectedUsersNotifier,
//                   builder: (context, selectedUsers, _) {
//                     if (selectedUsers.isNotEmpty) {
//                       return ListView.builder(
//                         itemCount: selectedUsers.length,
//                         itemBuilder: (context, index) {
//                           final user = selectedUsers[index];
//                           return ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: NetworkImage(user['profileImageUrl'] ?? ''),
//                               child: user['profileImageUrl'] == null
//                                   ? const Icon(Icons.person)
//                                   : null,
//                             ),
//                             title: Text(user['name'] ?? 'Unknown'),
//                             subtitle: Text(user['email'] ?? ''),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.close, color: Colors.red),
//                               onPressed: () => removeUserFromSelected(user['id']),
//                             ),
//                           );
//                         },
//                       );
//                     } else {
//                       return const Center(
//                         child: Text(
//                           "No users selected",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           // Nút Cancel
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("Cancel"),
//           ),
//
//           // Nút Save
//           TextButton(
//             onPressed: () {
//               if (selectedUsersNotifier.value.isNotEmpty) {
//                 Navigator.of(context).pop(selectedUsersNotifier.value);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("No users selected.")),
//                 );
//               }
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     // ImageGallerySaver.saveImage(Uint8List.fromList([]));
//     // khởi tao cac listener và xử lý ban đầu
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     // hủy bỏ các listener
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.friendName),
//         actions: [
//           GestureDetector(
//               onTap: addNewPersonIntoChat,
//               child: const Icon(
//                 Icons.person_add,
//               )),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             //hiển thị tin nhắn
//             Container(
//                 height: size.height / 1.25,
//                 width: size.width,
//                 child: StreamBuilder<QuerySnapshot>(
//                     stream: _firestore
//                         .collection('chats')
//                         .doc(widget.chatDocId)
//                         .collection('messenger')
//                         .orderBy("createOn", descending: false)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       return ListView.builder(
//                         itemCount: snapshot.data?.docs.length,
//                         itemBuilder: (context, index) {
//                           // Lấy một tin nhắn từ danh sách
//                           Map<String, dynamic>? map = snapshot.data?.docs[index]
//                               .data() as Map<String, dynamic>?;
//                           if (map != null) {
//                             return messages(size, map);
//                           } else {
//                             return CircularProgressIndicator(); // or any other =)))
//                           }
//                         },
//                       );
//                     })),
//
//             //nơi nhập tin nhắn va nut gửi
//             Container(
//               height: size.height / 10,
//               width: size.width,
//               alignment: Alignment.center,
//               child: Container(
//                 height: size.height / 12,
//                 width: size.width / 1.1,
//                 child: Row(
//                   children: [
//                     //Icon send ảnh
//                     IconButton(
//                       onPressed: _chonAnh,
//                       icon: Icon(Icons.image),
//                     ),
//
//                     //Input messenger
//                     Flexible(
//                       // height: size.height / 15,
//                       // width: size.width / 1.3,
//                       child: TextField(
//                         controller: _message,
//                         maxLines: null, //cho phep xuong dong
//                         keyboardType: TextInputType.multiline,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           hintText: "type messenger..",
//                           hintStyle: TextStyle(
//                               color: Theme.of(context).colorScheme.primary),
//                         ),
//                       ),
//                     ),
//
//                     //Icon send
//                     IconButton(
//                       onPressed: () =>
//                           onSendMessage(_messageController.text, 'text'),
//                       icon: Icon(Icons.send),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //Messenger buble
//   Widget messages(Size size, Map<String, dynamic> map) {
//     return Container(
//       width: size.width,
//       alignment: map["senderId"] != widget.myId
//           ? Alignment.centerLeft
//           : Alignment.centerRight,
//       child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(25),
//             color: map["senderId"] != widget.myId
//                 ? Theme.of(context).colorScheme.inversePrimary
//                 : Theme.of(context).colorScheme.primary,
//           ),
//           child: Column(
//             children: [
//               (map["msg"] != null || map["msgImageUrl"] != null)
//                   ? Column(
//                       children: [
//                         //Nếu hình ảnh ton tại
//                         (map["msgImageUrl"] != null)
//                             ? GestureDetector(
//                                 onTap: () {
//                                   _luuAnh(map["msgImageUrl"]);
//                                 },
//                                 child: CachedNetworkImage(
//                                     imageUrl: map["msgImageUrl"]))
//                             : const SizedBox(),
//
//                         //Nếu tin nhan ton tai
//                         (map["msg"] != null)
//                             ? Text(
//                                 map["msg"],
//                                 //STYLE OF MSG
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: map["senderId"] != widget.myId
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Theme.of(context)
//                                           .colorScheme
//                                           .inversePrimary,
//                                 ),
//                               )
//                             : const SizedBox(),
//                       ],
//                     )
//                   : const Text('Loading...'),
//             ],
//           )),
//     );
//   }
// }
class ChatPage extends StatefulWidget {
  final String myId;
  final String chatDocId;

  const ChatPage({
    super.key,
    required this.myId,
    required this.chatDocId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String appBarTitle = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  // Hàm load danh sách người tham gia và cập nhật title
  Future<void> _loadParticipants() async {
    final chatDoc = await _firestore.collection('chats')
        .doc(widget.chatDocId)
        .get();

    if (chatDoc.exists) {
      final data = chatDoc.data()!;
      final participants = List<String>.from(data['participate']);

      if (participants.isNotEmpty) {
        if (participants.length == 1) {
          setState(() {
            appBarTitle = "Chỉ mình bạn";
          });
        } else if (participants.length == 2) {
          final otherId = participants.firstWhere((id) => id != widget.myId);
          final otherUserDoc =
          await _firestore.collection('users').doc(otherId).get();
          setState(() {
            appBarTitle = otherUserDoc.data()?['name'] ?? "Unknown";
          });
        } else {
          // Xử lý nhiều hơn 2 người
          final otherIds = participants.where((id) => id != widget.myId)
              .toList();
          final otherNames = await Future.wait(
            otherIds.map((id) async {
              final userDoc = await _firestore.collection('users')
                  .doc(id)
                  .get();
              return userDoc.data()?['name'] ?? "Unknown";
            }),
          );

          setState(() {
            appBarTitle = otherNames.take(3).join(', ');
            if (otherNames.length > 3) appBarTitle += ",...";
          });
        }
      }
    }
  }

  Future<void> _chonAnh() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final String imageUrl = await _taiAnhLen(pickedImage.path);
      onSendMessage("", "image", imageUrl);
    }
  }

  Future<String> _taiAnhLen(String imagePath) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('chat_images/${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageReference.putFile(File(imagePath));
    await uploadTask.whenComplete(() {});

    return await storageReference.getDownloadURL();
  }

  void onSendMessage(String content, String type, [String? imageUrl]) async {
    if (content.isNotEmpty || type == 'image') {
      final message = Messenger(
        id: '',
        senderId: widget.myId,
        msg: content,
        msgImageUrl: imageUrl,
        createOn: DateTime.now(),
      );

      final firebaseChatRepo = FirebaseChatRepo();
      firebaseChatRepo.sendMessenger(widget.chatDocId, message);
      _message.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tin nhắn rỗng, vui lòng nhập vào.'),
        ),
      );
    }
  }

  void addNewPersonIntoChat() {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<List<Map<String, dynamic>>> searchResultsNotifier = ValueNotifier([]);
    final ValueNotifier<List<Map<String, dynamic>>> selectedUsersNotifier = ValueNotifier([]);

    void searchUsers(String query) async {
      final lowercaseQuery = query.toLowerCase();

      if (query.isNotEmpty) {
        final result = await FirebaseFirestore.instance.collection("users").get();

        final filteredUsers = result.docs.where((doc) {
          final lowercaseName = doc.data()['name'].toString().toLowerCase();
          return lowercaseName.startsWith(lowercaseQuery);
        }).toList();

        searchResultsNotifier.value = filteredUsers
            .map((doc) => {
          'id': doc.id,
          ...doc.data(),
        })
            .toList();
      } else {
        searchResultsNotifier.value = [];
      }
    }

    void addUserToSelected(Map<String, dynamic> user) {
      if (!selectedUsersNotifier.value.any((u) => u['id'] == user['id'])) {
        selectedUsersNotifier.value = [...selectedUsersNotifier.value, user];
      }
    }

    void removeUserFromSelected(String userId) {
      selectedUsersNotifier.value = selectedUsersNotifier.value.where((u) => u['id'] != userId).toList();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField để nhập từ khóa tìm kiếm
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                onChanged: (value) => searchUsers(value),
              ),
              const SizedBox(height: 10),

              // Khung hiển thị kết quả tìm kiếm
              Container(
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: searchResultsNotifier,
                  builder: (context, searchResults, _) {
                    if (searchResults.isNotEmpty) {
                      return ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user['profileImageUrl'] ?? ''),
                              child: user['profileImageUrl'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user['name'] ?? 'Unknown'),
                            subtitle: Text(user['email'] ?? ''),
                            onTap: () => addUserToSelected(user),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No users found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Khung hiển thị người dùng đã chọn
              Container(
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: selectedUsersNotifier,
                  builder: (context, selectedUsers, _) {
                    if (selectedUsers.isNotEmpty) {
                      return ListView.builder(
                        itemCount: selectedUsers.length,
                        itemBuilder: (context, index) {
                          final user = selectedUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user['profileImageUrl'] ?? ''),
                              child: user['profileImageUrl'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user['name'] ?? 'Unknown'),
                            subtitle: Text(user['email'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => removeUserFromSelected(user['id']),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No users selected",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Nút Cancel
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),

          // Nút Save
          TextButton(
            onPressed: () {
              if (selectedUsersNotifier.value.isNotEmpty) {
                Navigator.of(context).pop(selectedUsersNotifier.value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No users selected.")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            onPressed: addNewPersonIntoChat,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị tin nhắn
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatDocId)
                  .collection('messenger')
                  .orderBy("createOn", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final map = messages[index].data() as Map<String, dynamic>;
                    return _messageBubble(size, map);
                  },
                );
              },
            ),
          ),

          // Nhập tin nhắn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: _chonAnh,
                  icon: const Icon(Icons.image),
                ),
                Expanded(
                  child: TextField(
                    controller: _message,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary, ),
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),

                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onSendMessage(_message.text, 'text'),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Size size, Map<String, dynamic> map) {
    return Align(
      alignment: map["senderId"] == widget.myId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: map["senderId"] == widget.myId
              ? Theme.of(context).colorScheme.inversePrimary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: map["msg"] != null
            ? Text(
          map["msg"],
          style: TextStyle(
            color: map["senderId"] == widget.myId
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.inversePrimary,
          ),
        )
            : CachedNetworkImage(imageUrl: map["msgImageUrl"]),
      ),
    );
  }
}
