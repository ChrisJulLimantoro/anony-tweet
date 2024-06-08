import 'dart:math';
import 'package:intl/intl.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:anony_tweet/SessionProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  Future<String> getName(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('display_name')
        .eq('id', SessionContext.of(context)!.id)
        .single();
    return response['display_name'];
  }

  Future<String> getPhoto(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('display_photo')
        .eq('id', SessionContext.of(context)!.id)
        .single();
    return response['display_photo'];
  }

  Future<String> getDate(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('created_at')
        .eq('id', SessionContext.of(context)!.id)
        .single();
    return response['created_at'];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.search),
                onPressed: () {},
              ),
            ],
            pinned: true,
            floating: true,
            backgroundColor: Colors.grey.shade300,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: screenHeight * 0.10,
                        color: Colors.grey.shade300,
                      ),
                      Positioned(
                        top: screenHeight * 0.035,
                        left: screenWidth * 0.06,
                        child: Container(
                          width: screenWidth * 0.28,
                          height: screenWidth * 0.28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: screenWidth * 0.128,
                                child: FutureBuilder<String>(
                                  future: getPhoto(context),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Icon(Icons.error);
                                    } else if (snapshot.hasData) {
                                      return ClipOval(
                                        child: Image.network(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: screenWidth * 0.256,
                                          height: screenWidth * 0.256,
                                        ),
                                      );
                                    } else {
                                      return Image.asset(
                                          "lib/assets/logo/Logo.png");
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.11,
                        right: screenWidth * 0.03,
                        child: TextButton(
                          child: Text(
                            "Edit profile",
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            debugPrint("PRESSED");
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.07),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.085),
                  FutureBuilder<String>(
                    future: getName(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: Container(
                                    width: screenWidth * 0.7,
                                    child: Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: Container(
                                    width: screenWidth * 0.7,
                                    child: Text(
                                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: Container(
                                    width: screenWidth * 0.7,
                                    child: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.calendar,
                                          color: Colors.grey,
                                          size: screenHeight * 0.02,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        FutureBuilder<String>(
                                          future: getDate(context),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Image.asset(
                                                  "assets/logo/Logo.png");
                                            } else {
                                              return Text(
                                                '${DateFormat('dd MMM yyyy').format(DateTime.parse(snapshot.data!))}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: Container(
                                    width: screenWidth * 0.7,
                                    child: Row(
                                      children: [
                                        Text(
                                          "290",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          " Posts",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          "120",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          " Replies",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                _buildNavItem(0, 'Posts'),
                                _buildNavItem(1, 'Replies'),
                                _buildNavItem(2, 'Liked')
                              ],
                            ),
                            Container(
                              // height: screenHeight * 0.5,
                              child: _selectedIndex == 0
                                  ? PostsPage()
                                  : _selectedIndex == 1
                                      ? RepliesPage()
                                      : LikedPage(),
                            ),
                          ],
                        );
                      } else {
                        return Text('No data');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedIndex == index ? Colors.blue : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight:
                _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedIndex == index ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }
}

class PostsPage extends StatelessWidget {
  Future<List<Tweet>> fetchPost(BuildContext context) async {
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

    final userId = SessionContext.of(context)!.id;
    
    // Fetch user data
    final userResponse = await Supabase.instance.client
        .from('user')
        .select('display_name, display_photo')
        .eq('id', userId)
        .single();

    final displayName = userResponse['display_name'] ?? 'Unknown';
    final profilePicture = userResponse['display_photo'] ?? '';

    // Fetch tweets data
    final tweetResponse = await Supabase.instance.client
        .from('tweets')
        .select('*')
        .eq('creator_id', userId);


  List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(tweetResponse);

    List<Tweet> tweets = [];

    for (var tweet in data) {
      tweets.add(Tweet(
        id: userId,
        username: displayName,
        profilePicture: profilePicture,
        verified: Random().nextBool(),
        createdAt: timeAgo(DateTime.parse(tweet['created_at'])),
        content: tweet['content'] ?? '',
        media: tweet['media'] != null ? List<String>.from(tweet['media']) : [],
        like: tweet['like'] ?? 0,
        retweet: tweet['retweet'] ?? 0,
        comment: tweet['comment'] ?? 0,
        view: 100,
        isLiked: Random().nextBool(),
        isReTweet: Random().nextBool(),
      ));
    }

    print(tweets[0]);
    return tweets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: FutureBuilder<List<Tweet>>(
                future: fetchPost(context),
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
            );
  }
}

class RepliesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Liked Content',
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

class LikedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Liked Content',
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}
