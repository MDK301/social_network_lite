import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/data/firebase_auth_repo.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/auth_page.dart';
import 'package:social_network_lite/featured/post/presentation/pages/home_page.dart';
import 'package:social_network_lite/themes/dark_mode.dart';

import 'featured/auth/presentation/cubits/auth_states.dart';

class MyApp extends StatelessWidget {
  //auth repo
  final authRepo = FirebaseAuthRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
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
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
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

            )));
  }
}
