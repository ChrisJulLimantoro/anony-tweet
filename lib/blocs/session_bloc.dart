import 'package:crypt/crypt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

        print(response);
        return "User found";
      } else {
        return "Wrong Password!";
      }
    }
  }

  Future<String?> logout() async {
    session = null;
    id = null;
    final response = await client.auth.signOut();
  }
}
