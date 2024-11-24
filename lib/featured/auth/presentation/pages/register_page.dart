import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/auth/presentation/components/my_button.dart';
import 'package:social_network_lite/featured/auth/presentation/components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmpwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ), // Icon

                // welcome back msg
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ), // TextStyle
                ),
                const SizedBox(height: 25),

                // name textfield
                MyTextField(
                  controller: nameController,
                  hintText: "Name",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // pw textfield
                MyTextField(
                  controller: pwController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // re-pw textfield
                MyTextField(
                  controller: confirmpwController,
                  hintText: "Retype Password",
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                // login button
                MyButton(onTap: () {}, text: "Login"),
                const SizedBox(height: 50),

                // already a member? login now
                Text(
                  "Already a member? Login now",
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
