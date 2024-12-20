import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/post/presentation/component/post_tile.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_states.dart';
import 'package:social_network_lite/featured/post/presentation/pages/upload_post_page.dart';
import 'package:social_network_lite/responsive/constrainEdgeInsets_scaffold.dart';

import '../component/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //post cubit

  late final postCubit = context.read<PostCubit>();

  // on startup
  @override
  void initState() {
    super.initState();
    // fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // upload new post button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadPostPage(),
              ),
            ),
            icon: const Icon(Icons.add),
          )
        ],
      ),

      //SIDE MENU
      drawer: MyDrawer(),

      //BODY
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // loading..
          if (state is PostsLoading && state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          // loaded
          else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No posts available"),
              );
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                // get individual post
                final post = allPosts[index];

                // image
                return PostTile(
                  post: post,
                  onDeletePressed: () {
                    deletePost(post.id);
                  },
                );
              },
            );
          }

          // error
          else if (state is PostsError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            print("loi ngoai erro");
            return const SizedBox();
          }
        },
      ),
    );
  }
}
