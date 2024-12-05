import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/component/chat_tile.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_states.dart';

import '../../../auth/domain/entities/app_user.dart';

class AllChatPage extends StatefulWidget {
  final String uid;

  const AllChatPage({super.key, required this.uid});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ChatCubit, ChatStates>(builder: (context, state) {
        //loading
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        //loaded
        else if (state is AllChatLoaded) {
          final allChats = state.chats;

          if (allChats.isEmpty) {
            return const Center(
              child: Text("Start your chat now!  =w=  "),
            );
          }
          return ListView.builder(
            itemCount: allChats.length,
            itemBuilder: (context, index) {
              //get indivitual chat UwU~
              final chat = allChats[index];

              // image
              return ChatTile(
                chat: chat,
                curUid: currentUser!.uid,
              );
            },
          );
        } else {
          return const Center(
            child: Text("No profile found.."),
          );
        }
      }),
    );
  }
}
