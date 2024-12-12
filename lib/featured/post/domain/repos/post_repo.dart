import 'package:social_network_lite/featured/post/domain/entities/comment.dart';
import 'package:social_network_lite/featured/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> toggleLikeComment(String postId, String commentId, String userId);
  Future<void> addComments(String postId, Comment comment);
  Future<void> deleteComments(String postId, String commentId);

}