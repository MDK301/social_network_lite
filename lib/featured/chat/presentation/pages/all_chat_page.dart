
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/component/avatar_tile.dart';
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
  final TextEditingController searchController = TextEditingController();

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
      body: Container(

        child: Column(

          children: [
            SizedBox(
              height: 20,
              width: 460,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(hintText: "Search users..",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 80,
              width: 460,
              child:  StreamBuilder<List<Chat>>(
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

                  return ListView.builder(scrollDirection: Axis.horizontal,
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AvatarTile(
                          chat: chats[index],
                          curUid: currentUser!.uid,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 400,
              child: StreamBuilder<List<Chat>>(
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
            ),
          ],
        ),
      ),
    );
  }
}
