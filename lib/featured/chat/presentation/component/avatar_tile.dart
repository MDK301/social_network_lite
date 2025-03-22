import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/chat/presentation/pages/chat_page.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat.dart';

class AvatarTile extends StatefulWidget {
  final Chat chat;
  final String curUid;

  const AvatarTile({super.key, required this.chat, required this.curUid});

  @override
  State<AvatarTile> createState() => _AvatarTileState();
}

class _AvatarTileState extends State<AvatarTile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late var title = "loading...";

  String getOtherUid(Chat chat, String curUid) {
    return chat.participate.firstWhere((uid) => uid != curUid);
  }

  Future<void> _readed(String chatId, String userUid) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    try {
      await chatRef.update({
        'unread': FieldValue.arrayRemove([userUid]),
      });
      debugPrint('Successfully removed $userUid from unread list in $chatId');
    } catch (e) {
      debugPrint('Failed to remove $userUid from unread: $e');
    }
  }

  Future<void> _getGroupName(Chat chat) async {
    final chatDoc = await _firestore.collection('chats').doc(chat.id).get();

    if (chatDoc.exists) {
      final data = chatDoc.data()!;
      final participants = List<String>.from(data['participate']);

      if (participants.isNotEmpty) {
        if (participants.length == 1) {
          setState(() {
            title = "Chỉ mình bạn";
          });
        } else if (participants.length == 2) {
          final otherId = participants.firstWhere((id) => id != widget.curUid);
          final otherUserDoc =
          await _firestore.collection('users').doc(otherId).get();
          setState(() {
            title = otherUserDoc.data()?['name'] ?? "Unknown";
          });
        } else {
          final otherIds =
          participants.where((id) => id != widget.curUid).toList();
          final otherNames = await Future.wait(
            otherIds.map((id) async {
              final userDoc =
              await _firestore.collection('users').doc(id).get();
              return userDoc.data()?['name'] ?? "Unknown";
            }),
          );

          setState(() {
            title = otherNames.take(3).join(', ');
            if (otherNames.length > 3) title += ",...";
          });
        }
      }
    }
  }

  @override
  void initState() {
    _getGroupName(widget.chat);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String otherUid = getOtherUid(widget.chat, widget.curUid);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {

          return SizedBox(
            height: 50,
            width: 50,
            child: GestureDetector(
              // AVATAR
              child: FutureBuilder<ProfileUser?>(
                future: _fetchUserInfo(otherUid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final profileuser = snapshot.data!;
                    final profileImageUrl = profileuser.profileImageUrl;
                    if (profileImageUrl.isNotEmpty) {
                      return ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/image/icons8-person-30.png',
                          image: profileuser.profileImageUrl ?? '',
                          fit: BoxFit.cover,
                          height: 45,
                          width: 45,
                        ),
                      );
                    }else{
                      return const Icon(Icons.person,size: 45,);

                    }
                  } else {
                    return const Icon(Icons.person,size: 45,);
                  }
                },
              ),

              //Nhấn vào
              onTap: () {
                _readed(widget.chat.id, widget.curUid);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      myId: widget.curUid,
                      chatDocId: widget.chat.id,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<ProfileUser?> _fetchUserInfo(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        return ProfileUser.fromJson(
            userSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
    return null;
  }
}
