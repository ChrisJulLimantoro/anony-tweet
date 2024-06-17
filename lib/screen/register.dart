import 'dart:math';

import 'package:anony_tweet/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:faker/faker.dart';
import 'package:anony_tweet/widget/field.dart';
import 'package:crypt/crypt.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> insertData(BuildContext context) async {
    try {
      final response = await supabase.from('user').insert({
        'username': usernameController.text.trim(),
        'password': Crypt.sha256(passwordController.text.trim()).toString(),
        'display_name': WordPair.random().asPascalCase,
        'display_photo':
            "https://randomuser.me/api/portraits/men/${Random().nextInt(10000)}.jpg"
      });
      if (response != null && response.error != null) {
        throw Exception(response.error!.message);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // add delay than go to home
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // padding: const EdgeInsets.all(20.0),
        // color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset('lib/assets/logo/Logo.png'),
                  ),
                  const SizedBox(height: 16),
                  Field(
                    con: usernameController,
                    isPassword: false,
                    text: 'Username',
                    logo: Icons.person,
                  ),
                  const SizedBox(height: 16), // Add some spacing between fields
                  Field(
                    con: passwordController,
                    isPassword: true,
                    text: 'Password',
                    logo: Icons.lock,
                  ),
                  const SizedBox(height: 16),
                  Field(
                    con: confirmPasswordController,
                    isPassword: true,
                    text: 'Confirm Password',
                    logo: Icons.lock,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Log In'),
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
                  insertData(context);
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
                        'SignUp',
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
