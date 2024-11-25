import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/register_page.dart';

import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // initially, show login page
  bool showLoginPage = true;

// toggle between pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
          togglePages:togglePages,
      );
    } else {
      return RegisterPage(
        togglePages:togglePages,
      );
    }
  }
}
