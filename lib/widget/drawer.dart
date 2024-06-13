import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/main.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<String?> getDisplayName(BuildContext context) async {
    try {
      // Mengambil userId dari SessionContext
      final userId = SessionContext.of(context)!.id;

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
      final userId = SessionContext.of(context)!.id;

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: FutureBuilder<String?>(
              future: getDisplayName(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No tweets found.');
                } else {
                  return Text(snapshot.data!);
                }
              },
            ),
            accountEmail: Text('@' + faker.internet.userName()),
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
                      return CircularProgressIndicator();
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
            leading: Icon(CupertinoIcons.bookmark),
            title: Text('Bookmarks'),
            onTap: () {
              Navigator.pushNamed(context, '/bookmarks');
            },
          ),
          ListTile(
            leading: Icon(CupertinoIcons.gear),
            title: Text('Settings'),
            onTap: () {
              print('Settings pressed');
            },
          ),
        ],
      ),
    );
  }
}
