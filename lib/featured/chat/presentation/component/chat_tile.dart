import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/profile_page.dart';

import '../../domain/entities/chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final curUid;

  const ChatTile({super.key
    , required this.chat
    , required this.curUid
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(chat.name),
      subtitle: Text(user.email),
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