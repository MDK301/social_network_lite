import 'package:social_network_lite/featured/chat/domain/entities/messenger.dart';

import '../../domain/entities/chat.dart';

abstract class ChatStates {}

class ChatInitial extends ChatStates {}

class ChatLoading extends ChatStates {}

class ChatLoaded extends ChatStates {
  final List<Chat?> users;
  ChatLoaded(this.users);
}

class ChatError extends ChatStates {
  final String errormessage;
  ChatError(this.errormessage);
}

abstract class MessengerStates {}

class MessengerInitial extends MessengerStates {}

class MessengerLoading extends MessengerStates {}

class MessengerUpLoading extends MessengerStates {}

class MessengerLoaded extends MessengerStates {
  final List<Messenger?> messenger;
  MessengerLoaded(this.messenger);
}

class MessengerError extends MessengerStates {
  final String errorMessage;
  MessengerError(this.errorMessage);
}