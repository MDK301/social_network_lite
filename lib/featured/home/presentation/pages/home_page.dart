import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/post/presentation/component/post_tile.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_states.dart';
import 'package:social_network_lite/featured/post/presentation/pages/upload_post_page.dart';
import 'package:social_network_lite/responsive/constrainEdgeInsets_scaffold.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../component/my_drawer.dart';

//thêm danh sách nguoi da xem. ( ai load post nao thi post do se luu uid cua nguoi do.)
// sap xep danh sach bai viet:
// + BV nhieu tim: đếm số tim nhiều nhất trong top 10, chọn random 2
// + BV moi: chọn 2 bài đầu
// + BV cua nguoi co nhieu follow:
//      -nguoi co nhieu follow top 30 chọn random 3
//      -chon bai viet nhieu tim nhat cua 3 nguoi do
// + BV cua nguoi minh dang follow ( mới chưa xem nếu >15 chọn 5 random )
// + BC cua ban be chọn hết ( mới chưa xem tầm 20 bài)
// random những thằng trên top đầu bảo đảm những thứ này
// phần còn lại sẽ hiển thị randome toàm bộ phần còn lại

//cập nhật avatar current user at my drawer.

//khoa binh luan

//report bài viet

//kiem tra trang thai ket noi mang   connectivity_plus: ^3.0.6

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppUser? currentUser;

  // get current user
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  //post cubit

  late final postCubit = context.read<PostCubit>();

  // on startup
  @override
  void initState() {
    super.initState();
    // fetch all posts
    fetchAllPosts();

    //lay user
    getCurrentUser();
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

                print(post.privacy);
                if(post.privacy=="true") {

                  if (post.userId == currentUser!.uid) {
                    return PostTile(
                      post: post,
                      onDeletePressed: () {
                        deletePost(post.id);
                      },
                    );
                  } else {

                  }
                }else{

                  return PostTile(
                    post: post,
                    onDeletePressed: () {
                      deletePost(post.id);
                    },
                  );
                }
                // return PostTile(
                //   post: post,
                //   onDeletePressed: () {
                //     deletePost(post.id);
                //   },
                // );

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
