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
              ProfileUser.fromJson(userSnapshot );
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
      child: BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
        //state ok
        if (state is ProfileLoaded) {
          //tao bien title
          String title = "unknow";

          final otherUids = widget.chat.participate
              .where((uid) => uid != widget.curUid)
              .toList();
          final numOfParticipants = otherUids.length + 1;

          // //get loaded user
          ProfileUser user = state.profileUser;
          if (numOfParticipants == 2) {
            // Access user profile from map
            final userProfile = state.profileUser;
            // Display name of other user
            title = userProfile.name;
          } else {
            final userProfile =
                state.profileUser; // Access user profile from map
            final remainingCount = otherUids.length - 1;
            title = '${userProfile.name} và $remainingCount người khác';
          }
          print(widget.chat.id);
          print(user.name);

          return ListTile(
            title: _userInfo != null
                ? Text(_userInfo!['name'] as String)
                : const Text('Loading...'),
            subtitle: Text(user.email),
            subtitleTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.primary),
            leading: CachedNetworkImage(
              imageUrl: user.profileImageUrl,
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
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
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
                  friendId: user.uid,
                  friendName: user.name,
                  chatDocId: widget.chat.id,
                ),
              ),
            ),
          );
        }

        //state loading
        else if (state is ProfileLoading) {
          return const ConstrainedScaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //state khong tim thay
        else {
          return const Center(
            child: Text("No chat found.."),
          );
        }
      }),
    );
  }
}
