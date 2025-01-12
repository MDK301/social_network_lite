import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserStatusService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void setOnline(String? uid) {
    if (uid != null) {
      final userStatusRef = _database.child('userstatus').child(uid);
      userStatusRef.update({
        "status": "Online",
        "lastSeen": ServerValue.timestamp,
      });
      userStatusRef.onDisconnect().update({
        "status": "Offline",
        "lastSeen": ServerValue.timestamp,
      });
    }
  }

  void setOffline(String? uid) {
    if (uid != null) {
      final userStatusRef = _database.child('userstatus').child(uid);
      userStatusRef.update({
        "status": "Offline",
        "lastSeen": ServerValue.timestamp,
      });
    }
  }
}
