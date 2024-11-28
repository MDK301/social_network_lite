import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/post/presentation/pages/upload_post_page.dart';

import '../component/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary ,
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
      drawer:MyDrawer(),
    );
  }
}
