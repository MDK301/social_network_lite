import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/chat/presentation/pages/chat_page.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat.dart';

class ChatTile extends StatefulWidget {
  final Chat chat;
  final String curUid;

  const ChatTile({super.key, required this.chat, required this.curUid});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
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

    String _formatTimestamp(Timestamp timestamp) {
      final now = DateTime.now();
      final difference = now.difference(timestamp.toDate());

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final chatData = snapshot.data!.data() as Map<String, dynamic>;
          final lastMessage = chatData['lastMessenger'] as String?;
          final timestamp = chatData['lastMessengerTime'] as Timestamp?;
          final unread = chatData['unread'] as List<dynamic>? ?? [];

          return SizedBox(
            height: 50,
            child: ListTile(
              // TITLE
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: unread.contains(widget.curUid)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),

              // NAME + LAST MESSAGE
              subtitle: Text(
                lastMessage ?? '',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: unread.contains(widget.curUid)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: unread.contains(widget.curUid)
                      ? Theme.of(context).colorScheme.inversePrimary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),

              // TIME
              trailing: timestamp != null
                  ? Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: unread.contains(widget.curUid)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: unread.contains(widget.curUid)
                            ? Theme.of(context).colorScheme.inversePrimary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,

              // AVATAR
              leading: FutureBuilder<ProfileUser?>(
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
