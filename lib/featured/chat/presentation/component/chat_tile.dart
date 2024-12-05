import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/profile_page.dart';

import '../../domain/entities/chat.dart';

class ChatTile extends StatefulWidget {
  //lụm nội dung model chat và id nguoi dung hien tai
  final Chat chat;
  final curUid;

  const ChatTile({super.key
    , required this.chat
    , required this.curUid
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {

    //other uid
    final otherUids = widget.chat.participate.where((uid) => uid != widget.curUid).toList();
    final numOfParticipante=otherUids.length+1;



    Future<String> _getTitle() async {
      final otherUids = widget.chat.participate.where((uid) => uid != widget.curUid).toList();
      final names = <String>[];
      for (final uid in otherUids) {
        final userProfile = await firebaseProfileRepo.fetchUserProfile(uid);
        names.add(userProfile.name);
      }
      return names.join(', '); // Ghép các tên bằng dấu phẩy
    }



    return ListTile(
      title: Text(widget.chat.participate[0]),
      subtitle: Text(widget.user.email),
      subtitleTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      leading: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.primary,
      ),
      trailing: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(uid: user.uid),
        ),
      ),
    );
  }
}