import 'package:anony_tweet/screen/explore.dart';
import 'package:anony_tweet/screen/notifications.dart';
import 'package:anony_tweet/screen/app.dart';
import 'package:anony_tweet/screen/home.dart';
import 'package:anony_tweet/screen/login.dart';
import 'package:anony_tweet/screen/profile.dart';
import 'package:flutter/material.dart';
import 'screen/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('db_url'),
      anonKey: const String.fromEnvironment('db_anonKey'),
    );
    print(const String.fromEnvironment('db_url'));
    print(const String.fromEnvironment('db_anonKey'));
    runApp(const MyApp());
  } catch (e) {
    print('error $e');
  }
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Anony Tweets',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white38),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            background: Colors.black,
            primary: Colors.white,
            brightness: Brightness.dark,
            onPrimary: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.black,
          ),
          useMaterial3: true,
        ),
        home: App(),
        routes: {
          '/register': (context) => const RegisterPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => HomePage(),
          '/notifications': (context) => NotificationsPage(),
          '/profile': (context) => ProfilePage(),
          '/explore': (context) => ExplorePage(),
        });
  }
}
