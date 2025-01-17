import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/components/my_button.dart';
import 'package:social_network_lite/featured/auth/presentation/components/my_text_field.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/responsive/constrainEdgeInsets_scaffold.dart';

import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void login() {
// prepare email & pw
    final String email = emailController.text;
    final String pw = pwController.text;

// auth cubit
    final authCubit = context.read<AuthCubit>();

// ensure that the email & pw fields are not empty
    if (email.isNotEmpty && pw.isNotEmpty) {
      // login!
      authCubit.login(email, pw);
    }
// display error if some fields are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter both email and password'),
      ));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: SingleChildScrollView(
        child: SafeArea(
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
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
              // Icon

              // welcome back msg
              Text(
                "Welcome back, you've been missed!",
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ), // TextStyle
              ),
              const SizedBox(height: 25),

              // email textfield
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 25),

              // pw textfield
              MyTextField(
                controller: pwController,
                hintText: "Password",
                obscureText: true,
              ),
              const SizedBox(height: 25),

              // login button
              MyButton(onTap: login
                  , text: "Login"),
              Container(
                alignment: Alignment.centerRight,
                child: TextButton( onPressed: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                  );
                },
                child: Text("Quên mật khẩu"),),),
            const SizedBox(height: 50),


            // not a member? register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member?",
                  style:
                  TextStyle(color: Theme
                      .of(context)
                      .colorScheme
                      .primary),
                ), GestureDetector(
                  onTap: widget.togglePages,
                  child: Text(
                    " Register now",
                    style:
                    TextStyle(color: Theme
                        .of(context)
                        .colorScheme
                        .inversePrimary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
            ],
          ),
        ),
            ),),
      )
    ,
    );
  }
}
