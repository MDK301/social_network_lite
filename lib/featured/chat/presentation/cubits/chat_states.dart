import 'package:social_network_lite/featured/chat/domain/entities/messenger.dart';

import '../../domain/entities/chat.dart';

abstract class ChatStates {}

class ChatInitial extends ChatStates {}

class ChatLoading extends ChatStates {}

class AllChatLoaded extends ChatStates {
  final List<Chat> chats;
  AllChatLoaded(this.chats);
}
class ChatLoaded extends ChatStates {
  final Chat chat;
  ChatLoaded(this.chat);
}

class ChatError extends ChatStates {
  final String errormessage;
  ChatError(this.errormessage);
}


class MessengerInitial extends ChatStates {}

class MessengerLoading extends ChatStates {}

class MessengerUpLoading extends ChatStates {}

class MessengerLoaded extends ChatStates {
  final List<Messenger> messenger;
  MessengerLoaded(this.messenger);
}

class MessengerError extends ChatStates {
  final String errorMessage;
  MessengerError(this.errorMessage);
}