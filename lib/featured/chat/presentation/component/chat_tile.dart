import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/chat/presentation/pages/chat_page.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat.dart';

class ChatTile extends StatefulWidget {
  //lụm nội dung model chat và id nguoi dung hien tai
  final Chat chat;
  final String curUid;

  const ChatTile({super.key, required this.chat, required this.curUid});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  // ProfileUser? profileuser;

  Future<ProfileUser?> _fetchUserInfo(String uid) async {
    ProfileUser? profileuser;

    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        setState(() {
          profileuser =
              ProfileUser.fromJson(userSnapshot.data() as Map<String, dynamic>);
          // print(_profileuser!.profileImageUrl);
        });
        return profileuser;
      } else {
        // Xử lý trường hợp tài liệu ngườidùng không tồn tại
        // print('Tài liệu người dùng không tìm thấy cho uid: $uid');
        return null;
      }
    } catch (e) {
      // Xử lý lỗi
      // print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    String otherUid = getOtherUid(widget.chat, widget.curUid);

    late final profileCubit = context.read<ProfileCubit>();

    profileCubit.getUserProfile(otherUid);
    _fetchUserInfo(otherUid);

    //sua lai cach hien thi cua thoi gian <(") code nhu messenger
    String _formatTimestamp(Timestamp timestamp) {
      final now = DateTime.now();
      final difference = now.difference(timestamp.toDate());

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}giờ trước';
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
            // Cập nhật dữ liệu của ChatTile từ chatData
            final lastMessage = chatData['lastMessenger'] as String?;
            final senderUid = chatData['sender'] as String?;
            final timestamp = chatData['lastMessengerTime'] as Timestamp?;
            final unread = chatData['unread'] as List<dynamic>? ?? [];

            //test
            // final datetime=chatData['lastMessengerTime'];
            // final time=datetime.toDate();
            // print(datetime);

            return FutureBuilder<ProfileUser?>(
                future: _fetchUserInfo(otherUid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    ProfileUser? profileuser = snapshot.data;

                    return SizedBox(
                      height: 50,
                      child: ListTile(

                          //TITLE
                          title: Text(
                            profileuser?.name ?? 'loading',
                            style: TextStyle(
                              fontWeight: unread.contains(widget.curUid)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),

                          //NAME+LAST MSG
                          subtitle: FutureBuilder<ProfileUser?>(
                            future:
                                _fetchUserInfo(chatData['sender'] as String),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                final senderName = snapshot.data!.name;
                                return Text(
                                  '$senderName: ${lastMessage ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: unread.contains(widget.curUid)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: unread.contains(widget.curUid)
                                        ? Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return const Text('Đang tải...');
                              }
                            },
                          ),

                          //TIME
                          trailing: timestamp != null
                              ? Text(
                                  _formatTimestamp(timestamp),
                                  // time.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: unread.contains(widget.curUid)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: unread.contains(widget.curUid)
                                        ? Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : null,

                          //AVATAR
                          subtitleTextStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          leading: profileuser?.profileImageUrl != ''
                              ? ClipOval(
                                  child: FadeInImage.assetNetwork(
                                  placeholder:
                                      'assets/image/icons8-person-30.png',
                                  image: profileuser!.profileImageUrl ?? '',
                                  fit: BoxFit.cover,
                                  height: 45,
                                  width: 45,
                                ))
                              : const Icon(
                                  Icons.person,
                                ),
                          onTap: () async {
                            await _readed(
                              widget.chat.id,
                              widget.curUid,
                            );

                            //sang trang chat
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  myId: widget.curUid,
                                  // friendId: profileuser!.uid,
                                  // friendName: profileuser.name,
                                  chatDocId: widget.chat.id,
                                ),
                              ),
                            );
                          }),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                });
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
