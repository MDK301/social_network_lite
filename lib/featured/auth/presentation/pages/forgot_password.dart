import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/auth/data/firebase_auth_repo.dart'; // Import FirebaseAuthRepo

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();final _emailController = TextEditingController();
  String _message = '';
  final _authRepo = FirebaseAuthRepo(); // Tạo instance của FirebaseAuthRepo

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authRepo.resetPassword(_emailController.text); // Gọi hàm resetPassword từ FirebaseAuthRepo
        setState(() {
          _message = 'Email đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư của bạn.';
        });
      } on AuthException catch (e) {
        setState(() {
          _message = 'Lỗi: ${e.message}';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Đặt lại mật khẩu'),
              ),
              const SizedBox(height: 20),
              Text(_message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}