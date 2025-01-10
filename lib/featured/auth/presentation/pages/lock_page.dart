import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';

class LockPage extends StatelessWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản bị khóa'),
        automaticallyImplyLeading: false, // Không hiển thị nút back
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tài khoản của bạn đã bị khóa.\nXin liên lạc quản trị viên để biết thêm chi tiết.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // await FirebaseAuth.instance.signOut();
                  // // Chuyển hướng về trang đăng nhập (nếu cần)
                  // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  context.read<AuthCubit>().logout();

                },
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}