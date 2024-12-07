import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/chat/presentation/pages/chat_page.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../responsive/constrainEdgeInsets_scaffold.dart';
import '../../../profile/presentation/cubits/profile_states.dart';
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
  Map<String, dynamic>? _userInfo; // Biến để lưu trữ thông tin người dùng

  Future<void> _fetchUserInfo(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        setState(() {
          _profileuser =
              ProfileUser.fromJson(userSnapshot.data() as Map<String, dynamic>);
          print(_profileuser?.name);
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
  void initState() {
    // String late=getOtherUid(widget.chat,widget.curUid);
    // print(late);
    // String otherId= getOtherUid(widget.chat,widget.curUid);
    // profileCubit.fetchUserProfile(otherId);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // String late=getOtherUid(widget.chat,widget.curUid);

    // String otherId= getOtherUid(widget.chat,widget.curUid);
    // profileCubit.fetchUserProfile(otherId);

    super.didChangeDependencies();
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
            ? Text(_profileuser!.name as String)
            : const Text('Loading...'),
        subtitle: Text(_profileuser!.email),
        subtitleTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.primary),
        leading: CachedNetworkImage(
          imageUrl: _profileuser!.profileImageUrl,
          //loading...
          placeholder: (context, url) => const CircularProgressIndicator(),

          //error -> failed to load
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),

          //loaded
          imageBuilder: (context, imageProvider) => Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
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
