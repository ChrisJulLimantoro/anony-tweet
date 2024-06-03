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

  Future<List<Tweet>> fetchTweets() async {
    // Make the RPC call
    final response =
        await supabase.rpc('gettweet', params: {"search": "", "tag": ""});
    // Debugging response data and error (if any)
    // print(response);
    // Check if there is an error in the response
    // print("n");
    // Cast the response data to List<Map<String, dynamic>> if we're sure about the structure
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    List<Tweet> tweets = [];

    // Assuming tweetResponse.data is List<Map<String, dynamic>>
    for (var tweetData in response) {
      // Fetch username from 'user' table
      final userResponse = await supabase
          .from('user')
          .select('*') // Ensure to select 'username' if you need it
          .eq('id', tweetData['creator_id'])
          .single();

      if (userResponse == null) {
        // Handle no data or error
        print("User not found or error");
        continue; // Skip this iteration as we can't construct a valid Tweet without user data
      }

// Now safely access the username
      String username = userResponse['username'] ?? 'Unknown User';

      // print("User data: ${userResponse}");
// Provide a fallback value

      tweets.add(Tweet(
        username: userResponse['display_name'],
        profilePicture: userResponse['display_photo'],
        verified: Random()
            .nextBool(), // Consider using a more robust method or data from the database
        createdAt: tweetData['created_at'],
        content: tweetData['content'],
        media: [], // Assuming 'media' needs handling
        like: tweetData['like'],
        retweet: tweetData['retweet'],
        comment: tweetData['comment'],
        view: 100, // Static example, handle appropriately
      ));
    }
    print(tweets);
    return tweets;
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
              child: FutureBuilder<List<Tweet>>(
                future: fetchTweets(),
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
                            isLiked: true);
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
              accountName: Text(faker.person.name()),
              accountEmail: Text('@' + faker.internet.userName()),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: CircleAvatar(
                  backgroundColor:
                      theme == Brightness.light ? Colors.black : Colors.white,
                  child: Text(
                    faker.person.firstName()[0],
                    style: TextStyle(fontSize: 40.0),
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