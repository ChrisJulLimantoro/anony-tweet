import 'package:anony_tweet/widget/field.dart';
import 'package:flutter/material.dart';

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('lib/assets/logo/Logo.png'),
                ),
                const SizedBox(height: 50),

                Field(con: usernameController, isPassword: false, text: "Username", logo: Icons.person),
                const SizedBox(height: 20),
                Field(con: passwordController, isPassword: true, text: "Password", logo: Icons.lock),

                const SizedBox(height: 40),

                OutlinedButton.icon(
                  icon: const Icon(Icons.login, size: 24),
                  label: const Text('Login'),
                  onPressed: () {
                    print('Username: ${usernameController.text}');
                    print('Password: ${passwordController.text}');
                  },
                  style: OutlinedButton.styleFrom(minimumSize: const Size(300, 40)),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
