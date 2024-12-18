import 'package:cloud_firestore/cloud_firestore.dart';
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


  void toggleLikeComment() async {
    // Tham chiếu đến Firestore
    final firestore = FirebaseFirestore.instance;

    // Kiểm tra trạng thái "đã thích" hiện tại
    final isLiked = widget.comment.likes.contains(currentUser!.uid);

    try {
      // **Cập nhật giao diện người dùng trước (Optimistic UI)**
      setState(() {
        if (isLiked) {
          widget.comment.likes.remove(currentUser!.uid); // Bỏ thích
        } else {
          widget.comment.likes.add(currentUser!.uid); // Thích
        }
      });

      // **Lấy tài liệu bài đăng từ Firestore**
      final postDocRef = firestore.collection('posts').doc(widget.comment.postId);

      // **Chạy transaction để đảm bảo cập nhật an toàn**
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(postDocRef);

        if (!snapshot.exists) {
          throw Exception("Bài đăng không tồn tại");
        }

        List comments = snapshot.get('comments') as List;

        // **Tìm vị trí của comment trong mảng**
        int commentIndex = comments.indexWhere((c) => c['id'] == widget.comment.id);
        if (commentIndex == -1) {
          throw Exception("Bình luận không tồn tại");
        }

        // **Cập nhật mảng likes của bình luận**
        final updatedLikes = List<String>.from(comments[commentIndex]['likes']);
        if (isLiked) {
          updatedLikes.remove(currentUser!.uid); // Unlike
        } else {
          updatedLikes.add(currentUser!.uid); // Like
        }


        // **Thay đổi mảng comments với giá trị mới**
        comments[commentIndex]['likes'] = updatedLikes;

        // **Ghi lại mảng comments đã sửa vào Firestore**
        transaction.update(postDocRef, {'comments': comments});
      });
    } catch (error) {
      // **Quay lại giao diện cũ nếu có lỗi**
      setState(() {
        if (isLiked) {
          widget.comment.likes.add(currentUser!.uid); // Thêm lại thích
        } else {
          widget.comment.likes.remove(currentUser!.uid); // Bỏ lại không thích
        }
      });

      // **Hiển thị thông báo lỗi**
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật trạng thái thích: $error'),
        ),
      );
    }
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
