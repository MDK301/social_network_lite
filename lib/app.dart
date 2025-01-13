import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/data/firebase_auth_repo.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/auth_page.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/lock_page.dart';
import 'package:social_network_lite/featured/chat/data/firebase_chat_repo.dart';
import 'package:social_network_lite/featured/chat/presentation/cubits/chat_cubit.dart';
import 'package:social_network_lite/featured/post/data/firebase_post_repo.dart';
import 'package:social_network_lite/featured/post/presentation/cubits/post_cubit.dart';
import 'package:social_network_lite/featured/profile/data/firebase_profile_repo.dart';
import 'package:social_network_lite/featured/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_network_lite/featured/search/data/firebase_search_repo.dart';
import 'package:social_network_lite/featured/search/presentation/cubits/search_cubit.dart';
import 'package:social_network_lite/featured/storage/data/firebase_storage_repo.dart';
import 'package:social_network_lite/themes/theme_cubit.dart';
import 'AppLifeCycleObserver.dart';
import 'featured/auth/presentation/cubits/auth_states.dart';
import 'featured/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //auth repo
  final firebaseauthRepo = FirebaseAuthRepo();

  //profile repo
  final firebaseprofileRepo = FirebaseProfileRepo();

  //profile repo
  final firebasechatRepo = FirebaseChatRepo();

  //storage repo
  final firebasestorageRepo = FirebaseStorageRepo();

  //post repo
  final firebasepostRepo = FirebasePostRepo();

  //search repo
  final firebasesearchRepo = FirebaseSearchRepo();

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
          create: (context) =>
              ProfileCubit(profileRepo: firebaseprofileRepo, storageRepo: firebasestorageRepo),
        ),

        //chat cubit
        BlocProvider<ChatCubit>(
          create: (context) =>
              ChatCubit(chatRepo: firebasechatRepo, storageRepo: firebasestorageRepo),
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
        ),

        //theme cubit
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: AppLifecycleObserver(
        child: BlocBuilder<ThemeCubit, ThemeData>(builder: (context, currentTheme) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: currentTheme,
              //check auth
              home: BlocConsumer<AuthCubit, AuthState>(
                builder: (context, authState) {
                  // unauthenticated -> auth page (login/register)
                  if (authState is Unauthenticated) {
                    return const AuthPage();
                  }
                  // lock -> lockpage
                  if (authState is Lock) {
                    return const LockPage();
                  }
                  // authenticated -> home page
                  if (authState is Authenticated) {
                    return const HomePage();
                  }
                  // authenticated -> home page
                  if (authState is EmailVerificationRequired) {
                    return const AuthPage();
                  }

                  // loading..
                  else {
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
              ));
        }),
      ),
    );
  }
}