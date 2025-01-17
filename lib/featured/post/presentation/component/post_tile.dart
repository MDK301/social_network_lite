import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';
import 'package:social_network_lite/featured/auth/presentation/components/my_text_field.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/post/domain/entities/post.dart';
import 'package:social_network_lite/featured/post/presentation/component/comment_tile.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_states.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/profile_page.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/report.dart';

//container + padding + decoration + border = chỗ chứa + space + trang tri + khung
// child: Container(
// // padding:
// //     const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
// // decoration: BoxDecoration(
// //   //check viền
// //     border: Border.all(
// //       color: Theme.of(context).colorScheme.inversePrimary,
// //       width: 1,
// //     ),
// //     //bo góc
// //     borderRadius: BorderRadius.circular(8)),
// child: Text(
class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubit
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  // on startup,
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  void fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  //===========OPTION==============
  //show option box
  void showOptions(bool ownPost) {
    final TextEditingController reportController = TextEditingController();

    //this is for Report post
    Future<void> createReport(BuildContext context) async {

      //taoreport
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userReportId: currentUser!.uid,
        postId: widget.post.id,
        postOwnerId: widget.post.userId,
        reportContent: reportController.text,
        timeCreateReport: DateTime.now(),
      );

      try {
        final docRef = await FirebaseFirestore.instance
            .collection('reports').add(report.toJson());

        // Get the auto-generated ID
        final reportId = docRef.id;

        // Update the report object with the ID
        final updatedReport = report.copyWith(id: reportId);

        // Update the document in Firestore with the ID
        await docRef.update(updatedReport.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        Navigator.popUntil(
            context, (route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }

    //this is for lock cmt
    Future<void> lockComment(BuildContext context) async {
      try {
        final CollectionReference postsCollection =
            FirebaseFirestore.instance.collection('posts');
        final postDoc = await postsCollection.doc(widget.post.id).get();
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        if (postDoc.exists && postDoc.data() != null) {
          if (post.lock == "false") {
            await postsCollection.doc(widget.post.id).update({
              'lock': "true",
            });
          } else {
            await postsCollection.doc(widget.post.id).update({
              'lock': "false",
            });
          }
        } else {
          print("post empty");
        }
      } catch (e) {
        throw Exception(e);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: double.maxFinite, // Đảm bảo danh sách không bị tràn
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: isOwnPost ? 3 : 1, // Số lượng tùy chọn
            itemBuilder: (context, index) {
              if (index == 0) {
                //REPORT
                return ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text("REPORT"),
                  onTap: () {
                    Navigator.of(context).pop(); //Đóng dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("REPORT"),
                        content: SizedBox(
                          width: 400,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // TextField để nhập nội dung report
                              TextField(
                                controller: reportController,
                                decoration: InputDecoration(
                                  hintText: "What's wrong?",
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        actions: [
                          // Nút Cancel
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          // Nút Send
                          TextButton(
                            onPressed: () {
                              createReport(context);
                              // Navigator.popUntil(
                              //     context, (route) => route.isFirst);
                            },
                            child: const Text("Send"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (index == 1 && isOwnPost) {
                //DELETE
                return ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("DELETE POST"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Post?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel!"),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onDeletePressed!();
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (index == 2 && isOwnPost) {
                //LOCK CMT
                return ListTile(
                  leading: const Icon(Icons.lock),
                  //icon cho tùy chọn "lock cmt"
                  title: const Text("LOCK COMMENT"),
                  onTap: () async {
                    lockComment(context);
                    //update user
                    final fetchedUser =
                        await profileCubit.getUserProfile(widget.post.userId);
                    if (fetchedUser != null) {
                      setState(() {
                        postUser = fetchedUser;
                      });
                    }
                    postCubit.fetchAllPosts();
                    Navigator.of(context).pop(); // close dialog
                  },
                );
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  //===========LIKE==============
  // user tapped like button
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //optimize update post after like and UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); //unlike
      } else {
        widget.post.likes.add(currentUser!.uid); //like
      }
    });

    // update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      //co loi tra lai old value

      setState() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); //re-unlike
        } else {
          widget.post.likes.remove(currentUser!.uid); //re-like
        }
      }
    });
  }

  //===========COMMENTS==============
  // comment text controller
  final commentTextController = TextEditingController();

  // open comment box -> user wants to type a new comment
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MyTextField(
          controller: commentTextController,
          hintText: "Type a comment",
          obscureText: false,
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),

          // save button
          TextButton(
            onPressed: () {
              if (commentTextController.text.isNotEmpty) {
                addComment();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please fill the gap before saving.")));
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  //add comment
  void addComment() async {
    final CollectionReference postsCollection =
        FirebaseFirestore.instance.collection('posts');
    final postDoc = await postsCollection.doc(widget.post.id).get();
    final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

    // create a new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    // add comment using cubit
    if (post.lock == "false") {
      if (commentTextController.text.isNotEmpty) {
        postCubit.addComment(widget.post.id, newComment);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment save successfully!'),
          ),
        );
      } else {}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment on this post has been lock by author!'),
        ),
      );
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          //topsection
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    uid: widget.post.userId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // profile pic
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),

                  SizedBox(
                    width: 10,
                  ),

                  //name
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold),
                  ),

                  const Spacer(),

                  //option button
                  IconButton(
                    onPressed: () {
                      showOptions(isOwnPost);
                    },
                    icon: Icon(Icons.more_horiz),
                    color: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            ),
          ),

          //image
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          // buttons -> like, comment, timestamp
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // like button

                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      //LIKE BUTTON
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          //Chon icon
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          //custom mau theo tinh trang
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      SizedBox(
                        width: 5,
                      ),

                      //like count
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // comment button
                widget.post.lock == "false"
                    ? GestureDetector(
                        onTap: openNewCommentBox,
                        child: Icon(
                          Icons.comment,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                    : SizedBox(),

                SizedBox(
                  width: 5,
                ),

                widget.post.lock == "false"
                    ? Text(
                        widget.post.comments.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      )
                    : SizedBox(),

                const Spacer(),

                // timestamp
                Text(widget.post.timestamp.toString()),
              ],
            ),
          ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                // username
                Text(
                  widget.post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 10),

                // text
                Text(widget.post.text),
              ],
            ),
          ),

          // COMMENT SECTION
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              //LOADED
              if (state is PostsLoaded) {
                // final individual post
                final post = state.posts
                    .firstWhere((post) => (post.id == widget.post.id));

                if (post.comments.isNotEmpty) {
                  // SL comments to show
                  int showCommentCount = post.comments.length;

                  // comment section
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // get individual comment
                      final comment = post.comments[index];

                      // comment title UI
                      return CommentTile(
                        comment: comment,
                        uid: widget.post.userId,
                      );
                    },
                  );
                }
              }

              //LOADING
              if (state is PostsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // ERROR
              else if (state is PostsError) {
                return Center(child: Text(state.message));
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
