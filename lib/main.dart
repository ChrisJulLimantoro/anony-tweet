import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/screen/detail.dart';
import 'package:anony_tweet/screen/explore.dart';
import 'package:anony_tweet/screen/search.dart';
import 'package:anony_tweet/screen/notifications.dart';
import 'package:anony_tweet/screen/app.dart';
import 'package:anony_tweet/screen/home.dart';
import 'package:anony_tweet/screen/login.dart';
import 'package:anony_tweet/screen/post_comment.dart';
import 'package:anony_tweet/screen/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screen/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('db_url'),
      anonKey: const String.fromEnvironment('db_anonKey'),
    );
    final authResponse =
        await Supabase.instance.client.auth.signInAnonymously();

    // print("auth session: ${authResponse.session}");
    final Session session = authResponse.session!;
    final SharedPreferences savedUser = await SharedPreferences.getInstance();
    // savedUser.clear();
    final String? user = savedUser.getString('user');

    if (user != null) {
      final Map<String, dynamic> userMap = json.decode(user);
      final String id = userMap['id'];
      final String displayName = userMap['displayName'];
      final String displayPhoto = userMap['displayPhoto'];
      final String username = userMap['username'];
      final int expiry = userMap['expiry'];

      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await savedUser.remove('user');
      } else {
        print("user found!");
        runApp(BlocProvider(
          create: (context) => SessionBloc(
            session: session,
            id: id,
            displayName: displayName,
            displayPhoto: displayPhoto,
            username: username,
          ),
          child: const MyApp(),
        ));
        return;
      }
    }
    runApp(BlocProvider(
      create: (context) => SessionBloc(session: session, id: ''),
      child: const MyApp(),
    ));
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
        home: context.read<SessionBloc>().id == ""
            ? const LoginPage()
            : const App(),
        routes: {
          '/app': (context) => const App(),
          '/register': (context) => const RegisterPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => HomePage(),
          '/notifications': (context) => NotificationsPage(),
          '/profile': (context) => ProfilePage(),
          '/explore': (context) => ExplorePage(),
          '/search': (context) => SearchPage(
                initialSearch: null,
              ),
          '/comment': (context) => DetailPage(
              id: ModalRoute.of(context)!.settings.arguments as String),
          '/postComment': (context) => PostComment(),
        });
  }
}
