import 'dart:math';
import 'dart:ui';
import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/custom_fab.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anony_tweet/main.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final faker = Faker();
  final supabase = Supabase.instance.client;

  String timeAgo(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inDays >= 365) {
      int years = (difference.inDays / 365).floor();
      return "${years}y ago";
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return "${months}m ago";
    } else if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return "${weeks}w ago";
    } else if (difference.inDays >= 1) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inMinutes}m ago";
    } else {
      return "${difference.inSeconds}s ago";
    }
  }

  Future<List<Tweet>> fetchTweets(BuildContext context) async {
    final userId = SessionContext.of(context)!.id;
    // final userId = "455cb4a8-f014-4c1e-b394-0d6a05db3fdf";
    print(userId); // Contoh user_id

    // Mengambil daftar tweet_id yang disukai oleh user
    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    // print(likedTweetsResponse);
    // Mengekstrak tweet_id ke dalam Set untuk pencarian yang lebih cepat
    final likedTweetIds = <String>{};
    if (likedTweetsResponse != null) {
      for (var record in likedTweetsResponse) {
        likedTweetIds.add(record['tweet_id']);
      }
    }
    // Lanjutkan dengan mengambil tweet seperti sebelumnya
    final response =
        await supabase.rpc('gettweet', params: {"search": "", "tag": ""});
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    List<Tweet> tweets = [];
    for (var tweetData in data) {
      DateTime createdAt = DateTime.parse(tweetData['created_at']);
      final userResponse = await supabase
          .from('user')
          .select('*') // Pastikan untuk memilih kolom yang dibutuhkan saja
          .eq('id', tweetData['creator_id'])
          .single();

      if (userResponse == null) {
        continue;
      }

      String username = userResponse['username'] ?? 'Unknown User';

      tweets.add(Tweet(
          id: tweetData['id'],
          username: userResponse['display_name'],
          profilePicture: userResponse['display_photo'],
          verified: Random().nextBool(),
          createdAt: timeAgo(createdAt),
          content: tweetData['content'],
          media: [],
          like: tweetData['like'],
          retweet: tweetData['retweet'],
          comment: tweetData['comment'],
          view: 100,
          isLiked: likedTweetIds.contains(tweetData['id']),
          isReTweet: Random().nextBool()));
    }

    return tweets;
  }

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
    return Scaffold(
        body: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              "PCUFess",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            floating: true,
            pinned: true,
            leading: Builder(builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      size: 32,
                      color: (theme == Brightness.light
                          ? Colors.black
                          : Colors.white),
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                      // Navigator.pushNamed(context, '/profile');
                      debugPrint("PRESSED");
                    },
                  ),
                ),
              );
            }),
            actions: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.gear, size: 28),
                  onPressed: () {
                    debugPrint("PRESSED");
                  },
                ),
              ),
            ],
            backgroundColor: theme == Brightness.light
                ? Colors.white.withAlpha(200)
                : Colors.black.withAlpha(100),
            shape: Border(
              bottom: BorderSide(
                color: theme == Brightness.light
                    ? Colors.grey.shade200
                    : Colors.grey.shade800,
                width: 0.5, // Adjust the border width as needed
              ),
            ),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: FutureBuilder<List<Tweet>>(
                future: fetchTweets(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data!.isEmpty) {
                    return Center(child: Text('No tweets found.'));
                  } else {
                    return ListView(
                      shrinkWrap:
                          true, // Use shrinkWrap to make ListView work inside SingleChildScrollView
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling inside the ListView
                      children: snapshot.data!.map((tweet) {
                        return SingleTweet(
                            tweet: tweet,
                            isBookmarked: true,
                            isLast: false,
                            isLiked: tweet.isLiked);
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(),
      drawer: Drawer(
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
      ),
    ));
  }
}

// FutureBuilder<List<Tweet>>(
//         future: fetchTweets(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data!.isEmpty) {
//             return Center(child: Text('No tweets found.'));
//           } else {
//             return ListView(
//               children: snapshot.data!.map((tweet) {
//                 return ListTile(
//                   title: Text(tweet.username),
//                   subtitle: Text(tweet.content),
//                   trailing: Text("${tweet.like} Likes"),
//                 );
//               }).toList(),
//             );
//           }
//         },
//       ),

// tweets
//                       .mapIndexed(
//                         (index, tweet) => SingleTweet(
//                           tweet: tweet,
//                           isBookmarked:
//                               Random().nextDouble() <= 0.5 ? true : false,
//                           isLast: index == tweets.length - 1 ? true : false,
//                           isLiked: Random().nextDouble() <= 0.5 ? true : false,
//                         ),
//                       )
//                       .toList(),
