
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

  // fetch all chats
  Future<void> fetchAllMessengers(String chatId) async {
    try {
      emit(MessengerLoading());
      final messengers = await chatRepo.fetchAllMessengers(chatId);
      emit(MessengerLoaded(messengers));
    } catch (e) {
      emit(MessengerError("Failed to fetch chats: $e"));
    }
  }


  // delete chat from all chats   //done //uncheck
  Future<void> deleteChat(String chatId) async {
    try {
      await chatRepo.deleteChat(chatId);
      await fetchAllMessengers();
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
   return null;
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