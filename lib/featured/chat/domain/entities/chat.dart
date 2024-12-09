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

  // convert json -> chat
  // factory Chat.fromJson(Map<String, dynamic> json) {
  //   return Chat(
  //     id: json['id'],
  //     lastMessenger: json['lastMessenger'],
  //     lastMessengerTime:json['lastMessageTimestamp'] != null ? (json['lastMessengerTime'] as Timestamp).toDate():  ,
  //     participate: List<String>.from(json['participate']),
  //     unread: List<String>.from(json['unread'] ?? []),
  //   );
  // }
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      lastMessenger: json['lastMessenger']as String,
      sender: json['sender']as String? ??'',
      lastMessengerTime: json['lastMessageTimestamp'] != null
          ? (json['lastMessageTimestamp'] as Timestamp).toDate()
          :  DateTime.now(), // Assign null if lastMessageTimestamp is null
      participate: List<String>.from(json['participate']),
      unread: List<String>.from(json['unread'] ?? []),
    );
  }
}
// // Từ Firestore Document -> Chat
// factory Chat.fromFirestore(DocumentSnapshot doc) {
//   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//   return Chat(
//     id: doc.id,
//     lastMessenger: data['lastMessenger'] ?? '',
//     lastMessengerTime: (data['lastMessengerTime'] as Timestamp).toDate(),
//     participate: List<String>.from(data['participate'] ?? []),
//     unread: List<String>.from(data['unread'] ?? []),
//   );
// }
//
// // Từ Chat -> Map để lưu vào Firestore
// Map<String, dynamic> toFirestore() {
//   return {
//     'lastMessenger': lastMessenger,
//     'lastMessengerTime': lastMessengerTime,
//     'participate': participate,
//     'unread': unread,
//   };
// }