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
  ProfileUser? _profileuser;

  // toi muon dat tai day

  Future<void> _fetchUserInfo(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        setState(() {
          _profileuser =
              ProfileUser.fromJson(userSnapshot.data() as Map<String, dynamic>);
          // print(_profileuser!.profileImageUrl);
        });
      } else {
        // Xử lý trường hợp tài liệu ngườidùng không tồn tại
        print('Tài liệu người dùng không tìm thấy cho uid: $uid');
      }
    } catch (e) {
      // Xử lý lỗi
      print('Lỗi khi lấy thông tin người dùng: $e');
    }
  }

  String getOtherUid(Chat chat, String curUid) {
    return chat.participate.firstWhere((uid) => uid != curUid);
  }

  @override
  Widget build(BuildContext context) {
    String otherUid = getOtherUid(widget.chat, widget.curUid);

    late final profileCubit = context.read<ProfileCubit>();

    profileCubit.getUserProfile(otherUid);
    _fetchUserInfo(otherUid);
    return SizedBox(
      height: 50,
      child: ListTile(
        title: _profileuser != null
            ? Text(_profileuser!.name)
            : const Text('Loading...'),
        subtitle: _profileuser != null
            ? Text(_profileuser!.email)
            : const Text('Loading...'),
        subtitleTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.primary),
        leading: _profileuser != ''
            ? ClipOval(
                child: Image.network(
                _profileuser!.profileImageUrl,
                fit: BoxFit.cover,
                height: 45,
                width: 45,
              ))
            : const Icon(Icons.person),
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              myId: widget.curUid,
              friendId: _profileuser!.uid,
              friendName: _profileuser!.name,
              chatDocId: widget.chat.id,
            ),
          ),
        ),
      ),
    );
  }
}
