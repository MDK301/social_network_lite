import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';
import 'package:social_network_lite/featured/auth/presentation/components/my_text_field.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/responsive/constrainEdgeInsets_scaffold.dart';

import '../../domain/entities/post.dart';
import '../cubits/post_cubit.dart';
import '../cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {

  bool privacy=false;

  // mobile image pick
  PlatformFile? imagePickedFile;

// web image pick
  Uint8List? webImage;

// text controller -> caption
  final textController = TextEditingController();

  // current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // get current user
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // create & upload post
  void uploadPost() {
    // check if both image and caption are provided
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Both image and caption are required")),
      );
      return;
    }
    print(currentUser!.name);
    // create a new post object
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      privacy: privacy.toString(),
      likes:[],
      comments:[],
      lock: 'false',

    );

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }

    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        // loading or uploading..
        if (state is PostsLoading || state is PostUploading) {
          return const ConstrainedScaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //build upload page
        return buildUploadPage();
      },

      //toi trang trc sau khi done & post da load
      listener: (context, state) {
        if(state is PostsLoaded){
          Navigator.pop(context);
        }

      },
    );
  }

  Widget buildUploadPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [

          // upload button
          IconButton(
            onPressed: uploadPost,
            icon: const Icon(Icons.upload),
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // image preview for web
              if (kIsWeb && webImage != null) Image.memory(webImage!),
        
              // image preview for mobile
              if (!kIsWeb && imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!)),
        
              // pick image button
              MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: const Text("Pick Image"),
              ),
        
              // caption text box
              MyTextField(
                controller: textController,
                hintText: "Caption",
                obscureText: false,
              ),
              Row(children: [
                Checkbox(
                  value: privacy,
                  onChanged: (value) {
                    setState(() {
                      privacy = value!;
                    });
                  },
                ),
                const Text('Private Post'),
              ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
