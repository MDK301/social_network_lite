import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/data/firebase_auth_repo.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/auth_page.dart';
import 'package:social_network_lite/featured/post/data/firebase_post_repo.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';
import 'package:social_network_lite/featured/profile/data/firebase_profile_repo.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_network_lite/featured/search/data/firebase_search_repo.dart';
import 'package:social_network_lite/featured/search/presentation/cubits/search_cubit.dart';
import 'package:social_network_lite/featured/storage/data/firebase_storage_repo.dart';
import 'package:social_network_lite/featured/storage/domain/storage_repo.dart';
import 'package:social_network_lite/themes/dark_mode.dart';

import 'featured/auth/presentation/cubits/auth_states.dart';
import 'featured/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  //auth repo
  final firebaseauthRepo = FirebaseAuthRepo();

  //profile repo
  final firebaseprofileRepo = FirebaseProfileRepo();

  //profile repo
  final firebasestorageRepo = FirebaseStorageRepo();

  //post repo
  final firebasepostRepo=FirebasePostRepo();
  //search repo
  final firebasesearchRepo=FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //provider cubit to app

    return MultiBlocProvider(
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseauthRepo)..checkAuth(),
        ),

        //profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo: firebaseprofileRepo,storageRepo: firebasestorageRepo),
        ),

        //post cubit
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasepostRepo,
            storageRepo: firebasestorageRepo,
          ),
        ),

        //search cubit
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepo: firebasesearchRepo),
          // BlocProvider
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              // unauthenticated -> auth page (login/register)
              if (authState is Unauthenticated) {
                return const AuthPage();
              }

              // authenticated -> home page
              if (authState is Authenticated) {
                return const HomePage();
              }

              // loading..
              else {
                print("authState");
                print(authState);

                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                );
              }
            },

            // listen for errors.
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          )),
    );
  }
}
