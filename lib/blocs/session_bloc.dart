import 'package:crypt/crypt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionBloc extends Cubit<List> {
  final client = Supabase.instance.client;
  Session? session;
  String? id = "";

  SessionBloc({
    this.session,
    this.id,
  }) : super([session, id]);

  Future<String?> login(String username, String password) async {
    //  Future<void> login(BuildContext context) async {
    final response =
        await client.from('user').select().eq('username', username.trim());

    if (response.isEmpty) {
      return "User not found!";
    } else {
      if (Crypt(response[0]['password']).match(password.trim())) {
        id = await response[0]['id'];

        // store id into shared preferences
        SharedPreferences sharedUser = await SharedPreferences.getInstance();

        var loginInfo = {
          "id": id,
          "expiry": DateTime.now().millisecondsSinceEpoch + 60 * 60 * 24 * 7,
        };
        sharedUser.setString('user', json.encode(loginInfo));

        return "User found";
      } else {
        return "Wrong Password!";
      }
    }
  }

  Future<void> logout() async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.remove("user");

    await client.auth.signOut();
  }
}
