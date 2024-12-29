import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String? lastMessenger;
  final String? sender;
  final DateTime lastMessengerTime;
  final List<String> participate;
  final List<String> unread;

  Chat({
    required this.id,
    this.lastMessenger,
    this.sender,
    required this.lastMessengerTime,
    required this.participate,
     this.unread=const [],
  });

  //chuyển chat sang json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastMessenger': lastMessenger,
      'sender': sender,
      'lastMessengerTime': Timestamp.fromDate(lastMessengerTime),
      'participate': participate,
      'unread': unread,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      lastMessenger: json['lastMessenger']as String,
      sender: json['sender']as String? ??'',
      lastMessengerTime:
      // json['lastMessageTimestamp'] != null ?
      (json['lastMessengerTime'] as Timestamp).toDate()
          // :  DateTime.now()
      ,
      participate: List<String>.from(json['participate']),
      unread: List<String>.from(json['unread'] ?? []),
    );
  }
}
