import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';

class FriendRequestPage extends StatefulWidget {
  final ProfileUser user;

  const FriendRequestPage({super.key, required this.user});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final List<ProfileUser> requestList=[];
  Future<void> getRequestList(ProfileUser user) async {
    try {
      // Get the current user's document using the user's UID
      final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get the friendRequest field
      final friendRequestSnapshot = await currentUserDoc.get();
      final friendRequestList = friendRequestSnapshot.get('friendRequest') as List<dynamic>;

      // Fetch user information for each UID in friendRequestList
      final profileUsers = await Future.wait(friendRequestList.map((uid) async {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid as String).get();
        return ProfileUser.fromJson(userDoc.data()as Map<String,dynamic>);
      }));

      setState(() {
        requestList.clear(); // Clear the existing list
        requestList.addAll(profileUsers); // Add the retrieved profile users
      });
    } catch (e) {
      print('Error getting request list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child:ListView.builder(
              itemCount: requestList.length,
              itemBuilder: (context, index) {
                //get indivitual chat UwU~

                // image
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: requestList[index] != null ?
                  ListTile(
                    title:  Text(requestList[index].name),
                    subtitle: Text(requestList[index].email),
                    subtitleTextStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                    leading: requestList[index].profileImageUrl != ''
                        ? ClipOval(
                        child: Image.network(
                          requestList[index].profileImageUrl,
                          fit: BoxFit.cover,
                          height: 45,
                          width: 45,
                        ))
                        : const Icon(Icons.person),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          myId: widget.curUid,
                          friendId: _profileuser!.uid,
                          friendName: _profileuser!.name,
                          chatDocId: widget.chat.id,
                        ),
                      ),
                    ),
                  ) : Container(child: CircularProgressIndicator(),)
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}
