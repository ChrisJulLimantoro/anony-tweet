import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:faker/faker.dart';
import 'package:anony_tweet/widget/field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String generate = WordPair.random().asPascalCase;
  String profile = Faker().image.image();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // void _generateName() {
  //   setState(() => {
  //         generate = WordPair.random().asPascalCase,
  //         profile = faker.image.image(
  //           keywords: ['cat', 'dog', 'pig', 'cartoon'],
  //           random: true,
  //           width: 100,
  //           height: 100,
  //         ),
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     'Register',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(
      //       fontSize: 25,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.black,
      //     ),
      //   ),
      // ),
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
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(50.0),
                  //   child: SizedBox(
                  //     child: Image.network(profile ?? faker.image.image(),
                  //         fit: BoxFit.cover),
                  //     width: 100,
                  //     height: 100,
                  //   ),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SizedBox(width: 44.0),
                  //     Text(
                  //       generate,
                  //       style: const TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     IconButton(
                  //       icon: const Icon(Icons.refresh, color: Colors.black),
                  //       onPressed: () {
                  //         _generateName();
                  //       },
                  //     )
                  //   ],
                  // ),
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
                  print(
                      '${usernameController.text} + ${passwordController.text}');
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
