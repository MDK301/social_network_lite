import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/component/chat_tile.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_states.dart';

import '../../../../responsive/constrainEdgeInsets_scaffold.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';

class AllChatPage extends StatefulWidget {
  final String uid;

  const AllChatPage({super.key, required this.uid});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {


  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;
  late final profileCubit = context.read<ProfileCubit>();
  late final chatCubit = context.read<ChatCubit>();

  @override
  void initState() {
    profileCubit.fetchUserProfile(widget.uid);
    chatCubit.fetchChatsByUserId(widget.uid);
    print("init state");
    print(widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatStates>(builder: (context, state) {
              //loading
              if (state is ChatLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //loaded
              else if (state is AllChatLoaded)
              {
                final allChats = state.chats;

                if (allChats.isEmpty) {
                  return const Center(
                    child: Text("Start your chat now!  =w= ~ "),
                  );
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
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
                  ),
                );
              }
              else
              {
                return const Center(
                  child: Text("No chat found.."),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
