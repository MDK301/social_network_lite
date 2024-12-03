import 'package:cloud_firestore/cloud_firestore.dart';

class Messenger {
  final String id;
  final String senderId;
  final String? msgDocumentUrl;
  final String? msgImageUrl;
  final DateTime createOn;
  final String? msg;

  Messenger({
    required this.id,
    required this.senderId,
     this.msgDocumentUrl,
     this.msgImageUrl,
    required this.createOn,
     this.msg,
  });

  //chuyển Messenger sang json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'msgDocumentUrl': msgDocumentUrl,
      'msgImageUrl': msgImageUrl,
      'createOn': Timestamp.fromDate(createOn),
      'msg': msg,
    };
  }

  // convert json -> Messenger
  factory Messenger.fromJson(Map<String, dynamic> json) {
    return Messenger(
      id: json['id'],
      senderId: json['senderId'],
      msgDocumentUrl: json['msgDocumentUrl']?? '',
      msgImageUrl: json['msgImageUrl']?? '',
      createOn: (json['createOn'] as Timestamp).toDate(),
      msg: json['msg']?? '',
    );
  }




  // // Từ Firestore Document -> Messenger
  // factory Messenger.fromFirestore(DocumentSnapshot doc) {
  //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //   return Messenger(
  //     id: doc.id,
  //     chatDocumentUrl: data['chatDocumentUrl'] ?? '',
  //     chatImageUrl: data['chatImageUrl'] ?? '',
  //     createOn: (data['createOn'] as Timestamp).toDate(),
  //     msg: data['msg'] ?? '',
  //   );
  // }
  //
  // // Từ Messenger -> Map để lưu vào Firestore
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'chatDocumentUrl': chatDocumentUrl,
  //     'chatImageUrl': chatImageUrl,
  //     'createOn': createOn,
  //     'msg': msg,
  //   };
  // }
}
