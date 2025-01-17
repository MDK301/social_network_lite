import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';

import '../../auth/presentation/cubits/auth_cubit.dart';
import '../../profile/presentation/pages/profile_page.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;

  final List<ProfileUser> friendList=[];

  Future<void> getFriendList(String uid) async {
    try {
      // Get the current user's document using the user's UID
      final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      // Get the friendRequest field
      final friendRequestSnapshot = await currentUserDoc.get();
      final friendRequestList = friendRequestSnapshot.get('friendlist') as List<dynamic>;

      // Fetch user information for each UID in friendRequestList
      final profileUsers = await Future.wait(friendRequestList.map((uid) async {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid as String).get();
        return ProfileUser.fromJson(userDoc.data()as Map<String,dynamic>);
      }));

      setState(() {
        friendList.clear(); // Clear the existing list
        friendList.addAll(profileUsers); // Add the retrieved profile users
        // print(friendList[0].name);
      });
    } catch (e) {
      print('Error getting request list: $e');
    }
  }

  Future<void> removeFriend(String currentUserId, String friendUserId) async {
    try {
      final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final friendRequestSnapshot = await currentUserDoc.get();
      final friendRequestList = friendRequestSnapshot.get('friendlist') as List<dynamic>;

      // Remove the friend's UID from the list
      friendRequestList.remove(friendUserId);

      // Update the friendlist field in Firestore
      await currentUserDoc.update({'friendlist': friendRequestList});

      // Remove the current's UID from the list

      final secondUserDoc = FirebaseFirestore.instance.collection('users').doc(friendUserId);
      final secondRequestSnapshot = await secondUserDoc.get();
      final secondRequestList = secondRequestSnapshot.get('friendlist') as List<dynamic>;

      // Remove the current's UID from the list
      secondRequestList.remove(currentUserId);

      // Update the friendlist field in Firestore
      await secondUserDoc.update({'friendlist': secondRequestList});

      // Update the UI
      getFriendList(currentUser!.uid);



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed successfully!')),
      );
    } catch (e) {
      print('Error removing friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove friend: $e')),
      );
    }
  }
@override
  void initState() {
  getFriendList(currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("F R I E N D  L I S T"),),
      body: Column(
        children:  [
          Expanded(
            child:friendList.isNotEmpty ?
            ListView.builder(
              itemCount: friendList.length,
              itemBuilder: (context, index) {
                
                //get indivitual chat UwU~

                // image
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                    ListTile(
                        title:  Text(friendList[index].name),
                        subtitle: Text(friendList[index].email),
                        subtitleTextStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                        leading: friendList[index].profileImageUrl != ''
                            ? ClipOval(
                            child: Image.network(
                              friendList[index].profileImageUrl,
                              fit: BoxFit.cover,
                              height: 45,
                              width: 45,
                            ))
                            : const Icon(Icons.person),

                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.primary,
                        ),

                        onTap: () {

                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.push(context,MaterialPageRoute(
                            builder: (context) => ProfilePage(
                              uid:  friendList[index].uid,
                            ),
                          ),
                          );

                        },onLongPress: (){
                          showDialog(context: context, builder: (context)=>AlertDialog(
                            title: const Text("Delete this friend"),
                            content: const Text("Remove this person from you're friend list?"),
                            actions: [
                              // Nút Cancel
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                              // Nút Send
                              TextButton(
                                onPressed: () {
                                  removeFriend(currentUser!.uid,friendList[index].uid);
                                  Navigator.of(context).pop();
                                  // Navigator.popUntil(
                                  //     context, (route) => route.isFirst);
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          ));
                    },
                    )
                );
              },
            ):  Container(child: Text("Chua co ban! Hay them ban vao"),)

          ),
        ],
      ),
    );
  }
}
