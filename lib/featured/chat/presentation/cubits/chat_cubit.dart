
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/chat/domain/repos/chat_repo.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_states.dart';

import '../../../storage/domain/storage_repo.dart';
import '../../domain/entities/chat.dart';

class ChatCubit extends Cubit<ChatStates> {
  final ChatRepo chatRepo;
  final StorageRepo storageRepo;

  ChatCubit({
    required this.chatRepo,
    required this.storageRepo,
  }) : super(ChatInitial());

  // fetch all messengers
  Future<void> fetchAllMessengers(String chatId) async {
    try {
      // print("fetchAllMessengers");
      // print("intry");
      emit(MessengerLoading());
      final messengers = await chatRepo.fetchAllMessengers(chatId);
      // print("fetchAllMessengers");
      // print("intry-qua final");
      emit(MessengerLoaded(messengers));
    } catch (e) {
      emit(MessengerError("Failed to fetch chats: $e"));
      // print("fetchAllMessengers");
      // print("incatch");
    }
  }
  // fetch all chats
  Future<void> fetchChatsByUserId(String userId) async {
    try {
      // print("fetchChatsByUserId-cubit");
      // print("intry");
      emit(ChatLoading());
      final chats = await chatRepo.fetchChatsByUserId(userId);
      // print("fetchChatsByUserId-cubit");
      // print("intry-qua final");
      emit(AllChatLoaded(chats));
    } catch (e) {
      emit(ChatError("Failed to fetch chats: $e"));
      // print("fetchChatsByUserId-cubit");
      // print("incatch cubit");
    }
  }


  // delete chat from all chats   //done //uncheck
  Future<void> deleteChat(String chatId) async {
    try {
      await chatRepo.deleteChat(chatId);
      await fetchAllMessengers(chatId);
    } catch (e) {
      emit(ChatError("Failed to delete chat: $e"));
    }
  }

  Future<Chat?> createChat(String uid1, String uid2 )async{
   try{
     emit(ChatLoading());
     final curChat= await chatRepo.createChat(uid1, uid2);

     if (curChat != null) {
       emit(ChatLoaded(curChat));
       return curChat;

     } else {
       emit(ChatError("User not found"));
       return null;

     }
   }catch(e){
     emit(ChatError("Failed to create chats: $e"));
     return null;

   }

  }


  // // toggle like on a post
  // Future<void> toggleLikePost(String postId, String userId) async {
  //   try {
  //     await postRepo.toggleLikePost(postId, userId);
  //   } catch (e) {
  //     emit(PostsError("Failed to toggle like: $e"));
  //   }
  // }
  //
  // // add a comment to a post
  // Future<void> addComment(String postId, Comment comment) async {
  //   try {
  //     await postRepo.addComments(postId, comment);
  //     await fetchAllPosts();
  //   } catch (e) {
  //     emit(PostsError("Failed to add comment: $e"));
  //   }
  // }

}