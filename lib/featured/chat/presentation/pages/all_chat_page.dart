import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/component/chat_tile.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_states.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/messenger.dart';

class AllChatPage extends StatefulWidget {
  final String uid;

  const AllChatPage({super.key, required this.uid});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  List<Chat> _chat = []; // Biến để lưu trữ danh sách Messenger

  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;


  Future<void> _fetchChatByUserId(String uid) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participate', arrayContains: widget.uid)
        .get();

    setState(() {
      _chat = querySnapshot.docs.map((doc) {
        // Sử dụng Messenger.fromJson đe doi ve List
        return Chat.fromJson(doc.data() as Map<String,
            dynamic>); // Hoặc Messenger.fromJson(doc.data() as Map<String, dynamic>)
      }).toList();

    });
  }

  @override
  void initState() {
    _fetchChatByUserId(widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_chat != '') {
      return Scaffold(
      appBar: AppBar(title: Text("Y O U R  C H A T S"),),
      body: Column(
        children: [
          Expanded(
            child:ListView.builder(

              itemCount: _chat.length,
              itemBuilder: (context, index) {
                //get indivitual chat UwU~


                // image
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChatTile(

                    chat: _chat[index],
                    curUid: currentUser!.uid,
                  ),
                );
              },
            ),

          ),
        ],
      ),
    );
    } else {
      return const SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator());
    }
  }
}
