import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/post/domain/entities/comment.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  final String uid;

  const CommentTile({super.key, required this.comment, required this.uid});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  // current user
  AppUser? currentUser;
  bool isOwnComment = false;
  bool isOwnPost = false;
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnComment = (widget.comment.userId == currentUser!.uid);
    isOwnPost = (widget.uid == currentUser!.uid);
  }

  //===========DELETE==============
  //show option box
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel!"),
          ),

          // delete button
          TextButton(
            onPressed: () {
              context
                  .read<PostCubit>()
                  .deleteComment(widget.comment.postId, widget.comment.id);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  //===========LIKE/DISLIKE==============
  void toggleLikeComment() {
    // current like status
    final isLiked = widget.comment.likes.contains(currentUser!.uid);

    //optimize update post after like and UI
    setState(() {
      if (isLiked) {
        widget.comment.likes.remove(currentUser!.uid); //unlike
      } else {
        widget.comment.likes.add(currentUser!.uid); //like
      }
    });

    // update like
    postCubit
        .toggleLikeComment(widget.comment.postId,widget.comment.id, currentUser!.uid)
        .catchError((error) {
      //co loi tra lai old value
      setState() {
        if (isLiked) {
          widget.comment.likes.add(currentUser!.uid); //re-unlike
        } else {
          widget.comment.likes.remove(currentUser!.uid); //re-like
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // name
          Text(widget.comment.userName,
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(
            width: 10,
          ),

          // comment text
          Text(widget.comment.text),

          const Spacer(),

          if (isOwnComment ||isOwnPost)
            GestureDetector(
              onTap: showOptions,
              child: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

          GestureDetector(
            onTap: toggleLikeComment,
            child: Icon(
              //Chon icon
              widget.comment.likes.contains(currentUser!.uid)
                  ? Icons.favorite
                  : Icons.favorite_border,
              //custom mau theo tinh trang
              color: widget.comment.likes.contains(currentUser!.uid)
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(
            width: 5,
          ),

          //like count
          Text(
            widget.comment.likes.length.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ],

      ),
    );
  }
}
