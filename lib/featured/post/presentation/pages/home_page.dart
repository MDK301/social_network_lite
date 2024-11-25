import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';

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
        actions: [
          // logout button
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
