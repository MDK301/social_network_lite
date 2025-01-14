import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/pages/chat_page.dart';
import 'package:social_network_lite/featured/home/presentation/pages/friend_request_page.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_states.dart';
import 'package:social_network_lite/featured/profile/presentation/components/bio_box.dart';
import 'package:social_network_lite/featured/profile/presentation/components/follow_button.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/follower_page.dart';
import 'package:social_network_lite/responsive/constrainEdgeInsets_scaffold.dart';

import '../../../chat/domain/entities/chat.dart';
import '../../../post/presentation/component/post_tile.dart';
import '../components/profile_stats.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/profile_states.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late bool isfriend=false;
  // current user
  late AppUser? currentUser = authCubit.currentUser;

  //posts
  int postCount = 0;

  // on startup,
  @override
  void initState() {
    super.initState();
    // load user profile data
    isFriend(currentUser!.uid,widget.uid);
    profileCubit.fetchUserProfile(widget.uid);
  }

  //============FOLLOW OR NOT==============
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return; // return is profile is not loaded
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistically update UI
    setState(() {
      // unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }
      // follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });
    //perform actual toggle  in cubit
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      // revert update if there's an error
      setState(() {
        // unfollow
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }
        // follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  //addfriend
  Future<void> addfriend(String currentUid, String targetUid) async {
    try {
      // Get references to the target user's documents

      final targetUserDoc =
          FirebaseFirestore.instance.collection('users').doc(targetUid);

      // Get the current user's friendlist
      final currentUserSnapshot = await targetUserDoc.get();

      // Check if currentUid is already in the target's friendlist
      if (currentUserSnapshot.exists) {
        // Get the list of friend IDs from current user's friendlist
        List<dynamic> currentFriendList =
            currentUserSnapshot.data()?['friendlist'] ?? [];
        // print(currentFriendList[0]);

        // Check if targetUid is already in current user's friendlist
        if (currentFriendList.contains(targetUid)||currentFriendList.contains(currentUid)) {
          print('Bạn đã là bạn bè với người này.');
          return; // Không làm gì nếu đã là bạn bè
        } else {
          // Update friendRequest and friendList fields
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            transaction.update(targetUserDoc, {
              'friendRequest': FieldValue.arrayUnion([currentUid]),
              'friendlist': FieldValue.arrayUnion([]),
            });
          });
        }
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách bạn bè1: $e');
    }
  }

  //checkfriend
  Future<void> isFriend(String currentUid, String targetUid) async {
    try {
      // Get references to the target user's documents

      final targetUserDoc =
      FirebaseFirestore.instance.collection('users').doc(targetUid);

      // Get the current user's friendlist
      final currentUserSnapshot = await targetUserDoc.get();


        // Get the list of friend IDs from current user's friendlist
        List<dynamic> currentFriendList =
            currentUserSnapshot.data()?['friendlist'] ?? [];
        // Check if targetUid is already in current user's friendlist
        if (currentFriendList.contains(targetUid)||currentFriendList.contains(currentUid)) {
          print('Bạn đã là bạn bè với người này.');
          setState(() {
            isfriend=true;
          });

        } else {
          // Update friendRequest and friendList fields
          setState(() {
            isfriend=false;
          });
        }

    } catch (e) {
      print('Lỗi khi lấy danh sách bạn bè2: $e');
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    //is own post
    bool isOwnPost = (widget.uid == currentUser!.uid);
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // loaded
        if (state is ProfileLoaded) {
          //get loaded user
          final user = state.profileUser;

          // SCAFFOLD
          return ConstrainedScaffold(
            appBar: AppBar(
              title: Center(child: Text(user.name)),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [

                // request list profile button
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendRequestPage(user: user),
                      ),
                    ),
                    icon: const Icon(Icons.add_box),
                  ),

                // edit profile button
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    ),
                    icon: const Icon(Icons.settings),
                  ),

                // start chat button
                if (!isOwnPost)
                  IconButton(
                    onPressed: () async {
                      final chatCubit = context.read<ChatCubit>();
                      Chat? newChat = await chatCubit.createChat(
                          currentUser!.uid,
                          widget.uid); // Gọi createChat từ ChatCubit
                      String chatId = newChat!.id;
                      chatId.isEmpty
                          ? print("CHAT ID BI RONG ")
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  myId: currentUser!.uid,
                                  // friendId: user.uid,
                                  // friendName: user.name,
                                  chatDocId: chatId,
                                ),
                              ),
                            );
                    },
                    icon: const Icon(Icons.chat),
                  ),

                //add friend
                if (!isOwnPost)
                  SizedBox(
                    child:  (!isfriend)?
                      IconButton(
                      onPressed: () async {
                        try {
                          // Gọi hàm lấy danh sách bạn bè và yêu cầu kết bạn
                          await addfriend(currentUser!.uid, user.uid);
                        } catch (e) {
                          print('Lỗi khi lấy danh sách bạn bè: $e');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã Gửi Lời Mời Kết Bạn')),
                        );
                      },
                      icon: const Icon(Icons.person_add_rounded),
                    ): Container()
                  )
              ],
            ),

            // BODY
            body: ListView(
              children: [
                //email
                Center(
                  child: Text(
                    user.email,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 25),

                // profile pic
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,
                  //loading...
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),

                  //error -> failed to load
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  //loaded
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //profile stats
                ProfileStats(
                  postCount: postCount,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowerPage(
                        followers: user.followers,
                        following: user.following,
                      ),
                    ),
                  ), // ProfileStats
                ),

                const SizedBox(height: 25),

                //follow button
                if (!isOwnPost)
                  FollowButton(
                      onPressed: followButtonPressed,
                      isFollowing: user.followers.contains(currentUser!.uid)),

                const SizedBox(height: 25),

                //bio box
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                BioBox(text: user.bio),

                const SizedBox(height: 10),

                //posts
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25),
                  child: Row(
                    children: [
                      Text(
                        "Posts",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // list of posts from this user
                BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                  // posts loaded..
                  if (state is PostsLoaded) {
                    // filter posts by user id
                    final userPosts = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();

                    // Update postCount
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (postCount != userPosts.length) {
                        setState(() {
                          postCount = userPosts.length;
                        });
                      }
                    });

                    return ListView.builder(
                      itemCount: postCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // get individual post
                        final post = userPosts[index];

                        // return as post tile UI
                        return PostTile(
                          post: post,
                          onDeletePressed: () =>
                              context.read<PostCubit>().deletePost(post.id),
                        );
                      },
                    );
                  }

                  // posts loading..
                  else if (state is PostsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(
                      child: Text("No posts.."),
                    );
                  }
                })
              ],
            ),
          );
        }
        // loading...
        else if (state is ProfileLoading) {
          return const ConstrainedScaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No profile found.."),
          );
        }
      },
    );
  }
}
