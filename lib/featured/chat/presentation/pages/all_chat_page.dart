import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/component/chat_tile.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_states.dart';

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

  Future<void> _fetchChatByUserId(String uid) async {
    try {
      // Lấy dữ liệu từ Firestore
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participate', arrayContains: uid)
          .get();

      // Kiểm tra nếu có bất kỳ tài liệu nào thỏa mãn điều kiện
      if (chatSnapshot.docs.isNotEmpty) {
        // Duyệt qua các tài liệu (chats)
        for (var doc in chatSnapshot.docs) {
          // Lấy dữ liệu từ tài liệu
          var chatData = doc.data() as Map<String, dynamic>;

          // Ví dụ: Bạn có thể truy cập các trường trong tài liệu chat
          print('Chat ID: ${doc.id}');
          print('Chat Data: $chatData');

          // Nếu bạn muốn lấy thông tin người dùng từ tài liệu chat (ví dụ: lastMessenger)
          if (chatData['lastMessenger'] != null) {
            print('Last Messenger: ${chatData['lastMessenger']}');
          }
        }
      } else {
        // Nếu không có cuộc trò chuyện nào phù hợp
        print('Không tìm thấy cuộc trò chuyện cho uid: $uid');
      }
    } catch (e) {
      // Xử lý lỗi
      print('Lỗi khi lấy thông tin người dùng: $e');
    }
  }

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
            child:
                BlocBuilder<ChatCubit, ChatStates>(builder: (context, state) {
              //loading
              if (state is ChatLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //loaded
              else if (state is AllChatLoaded) {
                final allChats = state.chats;
                //kiem tra id chat lay ve
                print(allChats[0].id);
                print(allChats[1].id);

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
              } else {
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
