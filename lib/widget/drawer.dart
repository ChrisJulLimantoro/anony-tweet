import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/main.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<String?> getDisplayName(BuildContext context) async {
    try {
      // Mengambil userId dari SessionContext
      final userId = context.read<SessionBloc>().id ?? "";

      // Query ke supabase untuk mendapatkan display_name
      final response = await supabase
          .from('user')
          .select('display_name')
          .eq('id', userId)
          .single();
      print(response['display_name']);
      // Mengambil display_name dari data yang dihasilkan
      return response['display_name'];
    } catch (e) {
      // Handle error (misal menampilkan dialog error atau log)
      print('Error fetching display name: $e');
      return null;
    }
  }

  Future<String?> getDisplayPhoto(BuildContext context) async {
    try {
      // Mengambil userId dari SessionContext
      final userId = context.read<SessionBloc>().id ?? "";

      // Query ke supabase untuk mendapatkan display_name
      final response = await supabase
          .from('user')
          .select('display_photo')
          .eq('id', userId)
          .single();
      print(response['display_photo']);
      // Mengambil display_name dari data yang dihasilkan
      return response['display_photo'];
    } catch (e) {
      // Handle error (misal menampilkan dialog error atau log)
      print('Error fetching display photo: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    return Drawer(
      backgroundColor: theme == Brightness.light ? Colors.white : Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme == Brightness.light
                  ? Colors.blue
                  : Colors.blueGrey[800],
            ),
            accountName: FutureBuilder<String?>(
              future: getDisplayName(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CupertinoActivityIndicator(
                    radius: 14,
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No tweets found.');
                } else {
                  return Text(snapshot.data!);
                }
              },
            ),
            accountEmail: Text("Anonymous"
                // '@' + context.read<SessionBloc>().username.toString(),
                ),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                backgroundColor:
                    theme == Brightness.light ? Colors.black : Colors.white,
                child: FutureBuilder<String?>(
                  future: getDisplayPhoto(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator(
                        radius: 14,
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Image.asset("assets/logo/Logo.png");
                    } else {
                      return ClipOval(
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              CupertinoIcons.square_arrow_left,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              context.read<SessionBloc>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
