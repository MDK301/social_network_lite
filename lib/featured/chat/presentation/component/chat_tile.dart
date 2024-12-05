import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/profile_page.dart';

import '../../../../responsive/constrainEdgeInsets_scaffold.dart';
import '../../../profile/presentation/cubits/profile_states.dart';
import '../../domain/entities/chat.dart';

class ChatTile extends StatefulWidget {
  //lụm nội dung model chat và id nguoi dung hien tai
  final Chat chat;
  final String curUid;

  const ChatTile({super.key
    , required this.chat
    , required this.curUid
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {

  late final profileCubit = context.read<ProfileCubit>();

  // toi muon dat tai day


  String getOtherUid(Chat chat, String curUid) {
    return chat.participate.firstWhere(
          (uid) => uid != curUid
    );
  }

  @override
  void initState() {
    String otherId= getOtherUid(widget.chat,widget.curUid);
    profileCubit.fetchUserProfile(otherId);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {



    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {

        //state ok
      if (state is ProfileLoaded) {

        //tao bien title
        String title="unknow";


        final otherUids = widget.chat.participate.where((uid) => uid != widget.curUid).toList();
        final numOfParticipants = otherUids.length + 1;

        //get loaded user
        final user = state.profileUser;
        if (numOfParticipants == 2) {
          final otherUid = otherUids.first;
          // Access user profile from map
          final userProfile = state.profileUser; // Access user profile from map
          // Display name of other user
          title = userProfile.name ?? 'Unknown'; // Display name of other user
        } else {
          final otherUid = otherUids.first;
          final userProfile = state.profileUser; // Access user profile from map
          final remainingCount = otherUids.length - 1;
          title = '${userProfile.name ?? 'Unknown'} và $remainingCount người khác';
        }


        return ListTile(
          title: Text(widget.chat.participate[0]),
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

      }
    );
  }
}