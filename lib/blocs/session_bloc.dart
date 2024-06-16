import 'package:crypt/crypt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionBloc extends Cubit<void> {
  final client = Supabase.instance.client;
  Session? session;
  String? id = "";
  String? username = "";
  String? displayName = "";
  String? displayPhoto = "";

  SessionBloc({
    this.session,
    this.id,
    this.displayName,
    this.displayPhoto,
    this.username,
  }) : super([session, id, displayName, displayPhoto, username]);

  Future<String?> login(String username, String password) async {
    //  Future<void> login(BuildContext context) async {
    final response =
        await client.from('user').select().eq('username', username.trim());

    if (response.isEmpty) {
      return "User not found!";
    } else {
      if (Crypt(response[0]['password']).match(password.trim())) {
        print(response[0]);
        this.username = await response[0]['username'];
        id = await response[0]['id'];
        displayName = await response[0]['displayName'];
        displayPhoto = await response[0]['displayPhoto'];

        // store id into shared preferences
        SharedPreferences sharedUser = await SharedPreferences.getInstance();

        var loginInfo = {
          "id": id,
          "displayPhoto": response[0]['display_photo'],
          "username": response[0]['username'],
          "displayName": response[0]['display_name'],
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
