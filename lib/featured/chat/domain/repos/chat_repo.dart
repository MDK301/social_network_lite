import 'package:social_network_lite/featured/chat/domain/entities/chat.dart';
import 'package:social_network_lite/featured/chat/domain/entities/messenger.dart';

import '../../../profile/domain/entities/profile_user.dart';

abstract class ChatRepo {
  Future<List<Chat>> fetchAllChats();
  Future<void> createChat(String uid1 , String uid2);
  Future<void> deleteChat(String chatId);
  Future<void> updateChat(Chat updatedChat);
  Future<List<Chat>> fetchChatsByUserId(String userId);
  Future<void> sendMessenger(String messengerId,Messenger messenger);

}