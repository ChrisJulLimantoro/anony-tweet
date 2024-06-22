import 'dart:math';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        .eq('id', context.read<SessionBloc>().id ?? "")
        .single();
    return response['display_name'];
  }

  Future<String> getPhoto(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('display_photo')
        .eq('id', context.read<SessionBloc>().id ?? "")
        .single();
    return response['display_photo'];
  }

  Future<String> getDate(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('created_at')
        .eq('id', context.read<SessionBloc>().id ?? "")
        .single();
    return response['created_at'];
  }

  Future<int> fetchTweetCountByCreatorId(String creatorId) async {
    try {
      final response = await Supabase.instance.client
          .rpc('count_user_tweets', params: {'p_creator_id': creatorId});
      print(response);
      return response as int;
    } catch (e) {
      print('Error fetching tweet count: $e');
      return 0;
    }
  }

  Future<int> fetchTweetCountCommentByCreatorId(String creatorId) async {
    try {
      final response = await Supabase.instance.client
          .rpc('count_user_replies', params: {'p_creator_id': creatorId});
      print(response);
      return response as int;
    } catch (e) {
      print('Error fetching tweet count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final creatorId = context.read<SessionBloc>().id ?? "";

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
                                        FutureBuilder<int>(
                                          future: fetchTweetCountByCreatorId(
                                              creatorId),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text(
                                                "Loading...",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                "Error",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.red,
                                                ),
                                              );
                                            } else {
                                              return Text(
                                                snapshot.data.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              );
                                            }
                                          },
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
                                        FutureBuilder<int>(
                                          future:
                                              fetchTweetCountCommentByCreatorId(
                                                  creatorId),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text(
                                                "Loading...",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                "Error",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.red,
                                                ),
                                              );
                                            } else {
                                              return Text(
                                                snapshot.data.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              );
                                            }
                                          },
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
        return "${(difference.inDays / 365).floor()}y ago";
      } else if (difference.inDays >= 30) {
        return "${(difference.inDays / 30).floor()}m ago";
      } else if (difference.inDays >= 7) {
        return "${(difference.inDays / 7).floor()}w ago";
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

    final userId = context.read<SessionBloc>().id ?? "";

    final response = await Supabase.instance.client
        .rpc('get_posted_tweets', params: {'userid': userId});

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
    List<Tweet> tweets = [];

    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }


    for (var tweet in data) {
      final userResponse = await Supabase.instance.client
          .from('user')
          .select('display_name, display_photo')
          .eq('id', tweet['creator_id'])
          .single();
      bool isReTweet = tweet['retweet_id'] != null;
      String oriCreator = "";
      if (isReTweet) {
        final originalTweetResponse = await supabase
            .from('tweets')
            .select('*')
            .eq('id', tweet['retweet_id'])
            .single();
        final originalCreatorResponse = await supabase
            .from('user')
            .select('display_name')
            .eq('id', originalTweetResponse['creator_id'])
            .single();
        oriCreator = originalCreatorResponse['display_name'];
      } else {
        final response2 = "";
      }
      final retweetCountResponse = await supabase
          .from('tweets')
          .select()
          .eq('retweet_id', tweet['id'])
          .eq('creator_id', userId);

      int retweetCount = retweetCountResponse.length;
      print(retweetCount);

      bool isRetweetedByUser = false;
      if (retweetCount > 0) {
        isRetweetedByUser = true;
      }
      tweets.add(Tweet(
          id: tweet['id'],
          username: userResponse['display_name'],
          profilePicture: userResponse['display_photo'],
          verified: Random().nextBool(),
          createdAt: timeAgo(DateTime.parse(tweet['created_at'])),
          content: tweet['content'],
          media:
              tweet['media'] != null ? List<String>.from(tweet['media']) : [],
          like: tweet['like'],
          retweet: tweet['retweet'],
          comment: tweet['comment'],
          view: 0,
          isLiked: likedTweetIds.contains(tweet['id']),
          isReTweet: isReTweet,
          oriCreator: oriCreator,
          isRetweetedByUser: isRetweetedByUser));
    }
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
                            isLiked: tweet.isLiked,
                            searchTerm: '',
                          );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class RepliesPage extends StatelessWidget {
  Future<List<Tweet>> fetchPost(BuildContext context) async {
    String timeAgo(DateTime timestamp) {
      DateTime now = DateTime.now();
      Duration difference = now.difference(timestamp);

      if (difference.inDays >= 365) {
        return "${(difference.inDays / 365).floor()}y ago";
      } else if (difference.inDays >= 30) {
        return "${(difference.inDays / 30).floor()}m ago";
      } else if (difference.inDays >= 7) {
        return "${(difference.inDays / 7).floor()}w ago";
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

    final userId = context.read<SessionBloc>().id ?? "";

    final response = await Supabase.instance.client
        .rpc('find_comments_by_user', params: {'userid': userId});

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
    List<Tweet> tweets = [];

    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }

    for (var tweet in data) {
      final userResponse = await Supabase.instance.client
          .from('user')
          .select('display_name, display_photo')
          .eq('id', tweet['creator_id'])
          .single();
      bool isReTweet = tweet['retweet_id'] != null;
      String oriCreator = "";
      if (isReTweet) {
        final originalTweetResponse = await supabase
            .from('tweets')
            .select('*')
            .eq('id', tweet['retweet_id'])
            .single();
        final originalCreatorResponse = await supabase
            .from('user')
            .select('display_name')
            .eq('id', originalTweetResponse['creator_id'])
            .single();
        oriCreator = originalCreatorResponse['display_name'];
      } else {
        final response2 = "";
      }
      final retweetCountResponse = await supabase
          .from('tweets')
          .select()
          .eq('retweet_id', tweet['id'])
          .eq('creator_id', userId);

      int retweetCount = retweetCountResponse.length;
      print(retweetCount);

      bool isRetweetedByUser = false;
      if (retweetCount > 0) {
        isRetweetedByUser = true;
      }
      tweets.add(Tweet(
          id: tweet['id'],
          username: userResponse['display_name'],
          profilePicture: userResponse['display_photo'],
          verified: Random().nextBool(),
          createdAt: timeAgo(DateTime.parse(tweet['created_at'])),
          content: tweet['content'],
          media:
              tweet['media'] != null ? List<String>.from(tweet['media']) : [],
          like: tweet['like'],
          retweet: tweet['retweet'],
          comment: tweet['comment'],
          view: 0,
          isLiked: likedTweetIds.contains(tweet['id']),
          isReTweet: isReTweet,
          oriCreator: oriCreator,
          isRetweetedByUser: isRetweetedByUser));
    }
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
                  isLiked: tweet.isLiked,
                  searchTerm: '',
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class LikedPage extends StatelessWidget {
  Future<List<Tweet>> fetchPost(BuildContext context) async {
    String timeAgo(DateTime timestamp) {
      DateTime now = DateTime.now();
      Duration difference = now.difference(timestamp);

      if (difference.inDays >= 365) {
        return "${(difference.inDays / 365).floor()}y ago";
      } else if (difference.inDays >= 30) {
        return "${(difference.inDays / 30).floor()}m ago";
      } else if (difference.inDays >= 7) {
        return "${(difference.inDays / 7).floor()}w ago";
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

    final userId = context.read<SessionBloc>().id ?? "";

    final response = await Supabase.instance.client
        .rpc('get_user_liked_tweets', params: {'p_user_id': userId});

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
    List<Tweet> tweets = [];

    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }

    for (var tweet in data) {
      final userResponse = await Supabase.instance.client
          .from('user')
          .select('display_name, display_photo')
          .eq('id', tweet['creator_id'])
          .single();
      bool isReTweet = tweet['retweet_id'] != null;
      String oriCreator = "";
      if (isReTweet) {
        final originalTweetResponse = await supabase
            .from('tweets')
            .select('*')
            .eq('id', tweet['retweet_id'])
            .single();
        final originalCreatorResponse = await supabase
            .from('user')
            .select('display_name')
            .eq('id', originalTweetResponse['creator_id'])
            .single();
        oriCreator = originalCreatorResponse['display_name'];
      } else {
        final response2 = "";
      }
      final retweetCountResponse = await supabase
          .from('tweets')
          .select()
          .eq('retweet_id', tweet['id'])
          .eq('creator_id', userId);

      int retweetCount = retweetCountResponse.length;
      print(retweetCount);

      bool isRetweetedByUser = false;
      if (retweetCount > 0) {
        isRetweetedByUser = true;
      }
      tweets.add(Tweet(
          id: tweet['id'],
          username: userResponse['display_name'],
          profilePicture: userResponse['display_photo'],
          verified: Random().nextBool(),
          createdAt: timeAgo(DateTime.parse(tweet['created_at'])),
          content: tweet['content'],
          media:
              tweet['media'] != null ? List<String>.from(tweet['media']) : [],
          like: tweet['like'],
          retweet: tweet['retweet'],
          comment: tweet['comment'],
          view: 0,
          isLiked: likedTweetIds.contains(tweet['id']),
          isReTweet: isReTweet,
          oriCreator: oriCreator,
          isRetweetedByUser: isRetweetedByUser));
    }
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
                  isLiked: tweet.isLiked,
                  searchTerm: '',
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
