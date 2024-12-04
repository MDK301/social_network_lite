import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_network_lite/featured/chat/domain/entities/chat.dart';
import 'package:social_network_lite/featured/chat/domain/entities/messenger.dart';
import 'package:social_network_lite/featured/chat/domain/repos/chat_repo.dart';

class FirebaseChatRepo implements ChatRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the messenger in a collection called 'chats'
  final CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection('chats');

  @override
  Future<void> sendMessenger(String chatId, Messenger messenger) async {
    try {
      // Lấy tài liệu chatId
      final messengerDoc = await chatsCollection.doc(chatId).get();

      if (!messengerDoc.exists) {
        throw Exception('Chat with ID $chatId does not exist');
      }

      // Tạo tham chiếu đến collection `messenger`
      CollectionReference chatCollection =
          chatsCollection.doc(chatId).collection('messenger');

      // Chuyển đổi Messenger sang JSON và thêm vào Firestore
      final docRef = await chatCollection.add(messenger.toJson());

      // Cập nhật messenger với ID của document vừa tạo
      await docRef.update({
        'id': docRef.id, // Gán ID vừa tạo vào trường 'id'
      });
      print('Messenger added successfully!');
    } catch (e) {
      print('Error adding messenger: $e');
      throw Exception('Failed to add messenger');
    }
  }

  @override
  Future<Chat?> createChat(String uid1, String uid2) async {
    try {
      // Truy vấn tài liệu trong collection 'chats' nơi 'participate' chứa uid1
      QuerySnapshot querySnapshot =
          await chatsCollection.where('participate', arrayContains: uid1).get();

      // Sử dụng biến để chứa kết quả lọc
      QueryDocumentSnapshot? existingChat;
      for (var doc in querySnapshot.docs) {
        if (List.from(doc['participate']).contains(uid2)) {
          existingChat = doc;
          break;
        }
      }
      if (existingChat != null) {
        // Nếu đã tồn tại, trả về thông tin chat
        print("Chat already exists with ID: ${existingChat.id}");
        return Chat(
          id: existingChat.id,
          lastMessengerTime: (existingChat['lastmessengerTime'] as Timestamp).toDate(),
          participate: List<String>.from(existingChat['participate']),
        );
      } else {
        // Nếu không tồn tại, tạo tài liệu mới
        // Generate a new document ID
        DocumentReference docRef = chatsCollection.doc();

        // Current timestamp
        Timestamp currentTimestamp = Timestamp.now();

        // Create the chat document
        await docRef.set({
          'id': docRef.id,
          'lastMessenger': '',
          'lastmessengerTime': currentTimestamp,
          'participate': [uid1, uid2],
          'unread': [uid1, uid2],
        });

        print("Chat created successfully with ID: ${docRef.id}");
        return Chat(
            id: docRef.id,
            lastMessengerTime: Timestamp.now().toDate(),
            participate: [uid1, uid2]);
      }
    } catch (e) {
      print("Error creating chat: $e");
      return null;
    }
  }

  @override
  Future<List<Messenger>> fetchAllMessengers(String chatId) async {
    try {
      // get all posts with most recent posts at the top
      final chatsSnapshot = await chatsCollection
          .orderBy('createOn', descending: true)
          .get();

      // convert each firestore document from json -> list of posts
      final List<Chat> allChats = chatsSnapshot.docs
          .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allChats;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<List<Chat>> fetchChatsByUserId(String userId) async {
    try {
      // get all posts with most recent posts at the top
      final chatsSnapshot = await chatsCollection
          .where('participate', arrayContains: userId)
          .get();

      // convert each firestore document from json -> list of posts
      final List<Chat> allChats = chatsSnapshot.docs
          .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allChats;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<void> updateChat(Chat updatedChat) {
    // TODO: implement updateChat
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await chatsCollection.doc(chatId).delete();
  }
}
