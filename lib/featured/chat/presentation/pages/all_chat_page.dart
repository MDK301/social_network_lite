// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
// import 'package:social_network_lite/featured/chat/presentation/component/chat_tile.dart';
//
// import '../../../auth/domain/entities/app_user.dart';
// import '../../domain/entities/chat.dart';
//
// class AllChatPage extends StatefulWidget {
//   final String uid;
//
//   const AllChatPage({super.key, required this.uid});
//
//   @override
//   State<AllChatPage> createState() => _AllChatPageState();
// }
//
// class _AllChatPageState extends State<AllChatPage> {
//   List<Chat> _chat = []; // Biến để lưu trữ danh sách Messenger
//
//   late final authCubit = context.read<AuthCubit>();
//   late AppUser? currentUser = authCubit.currentUser;
//
//
//   Future<void> _fetchChatByUserId(String uid) async {
//     final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('chats')
//         .where('participate', arrayContains: widget.uid)
//         .get();
//
//     setState(() {
//       _chat = querySnapshot.docs.map((doc) {
//         // Sử dụng Messenger.fromJson đe doi ve List
//         return Chat.fromJson(doc.data() as Map<String,dynamic>);
//       }).toList();
//       // Sort the _chat list based on lastMessengerTime in descending order
//       // _chat.sort((a, b) => b.lastMessengerTime.compareTo(a.lastMessengerTime));
//
//       _chat.sort((a, b) {
//         return b.lastMessengerTime.compareTo(a.lastMessengerTime); // So sánh DateTime
//       });
//
//     });
//
//   }
//
//   @override
//   void initState() {
//     _fetchChatByUserId(widget.uid);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_chat.isNotEmpty) {
//       return Scaffold(
//       appBar: AppBar(title: Text("Y O U R  C H A T S"),),
//       body: Column(
//         children: [
//           Expanded(
//             child:ListView.builder(
//
//               itemCount: _chat.length,
//               itemBuilder: (context, index) {
//                 //get indivitual chat UwU~
//
//
//                 // image
//                 return Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: ChatTile(
//                     chat: _chat[index],
//                     curUid: currentUser!.uid,
//                   ),
//                 );
//               },
//             ),
//
//           ),
//         ],
//       ),
//     );
//     } else {
//       return Container(
//         color: Colors.white,
//         child: const SizedBox(
//             height: 12,
//             width: 12,
//             child: CircularProgressIndicator()),
//       );
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/component/chat_tile.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/chat.dart';

class AllChatPage extends StatefulWidget {
  final String uid;

  const AllChatPage({super.key, required this.uid});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;

  Stream<List<Chat>> _getChatStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participate', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Chat.fromJson(doc.data());
      }).toList()
        ..sort((a, b) => b.lastMessengerTime.compareTo(a.lastMessengerTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Y O U R  C H A T S"),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _getChatStream(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred while loading chats."),
            );
          }

          final chats = snapshot.data;

          if (chats == null || chats.isEmpty) {
            return const Center(
              child: Text("No chats available."),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ChatTile(
                  chat: chats[index],
                  curUid: currentUser!.uid,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
