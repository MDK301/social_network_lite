import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserStatusService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void setOnline() {
    final user = _auth.currentUser;
    if (user != null) {
      final userStatusRef = _database.child('userstatus').child(user.uid);
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
}