import 'package:anony_tweet/widget/field.dart';
import 'package:flutter/material.dart';
import 'package:anony_tweet/main.dart';
import 'package:crypt/crypt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select()
        .eq('username', usernameController.text.trim());
    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      if (Crypt(response[0]['password'])
          .match(passwordController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User found'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong Password!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset('lib/assets/logo/Logo.png'),
                  ),
                  const SizedBox(height: 50),
                  Field(
                      con: usernameController,
                      isPassword: false,
                      text: "Username",
                      logo: Icons.person),
                  const SizedBox(height: 20),
                  Field(
                      con: passwordController,
                      isPassword: true,
                      text: "Password",
                      logo: Icons.lock),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Don't have account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  print(
                      '${usernameController.text} + ${passwordController.text}');
                  login(context);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.deepPurple,
                    textStyle: const TextStyle(
                      color: Colors.white,
                    )),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
