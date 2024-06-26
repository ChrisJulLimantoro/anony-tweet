import 'dart:ui';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/custom_fab.dart';
import 'package:anony_tweet/widget/drawer.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Tweet>> _tweets;

  @override
  void initState() {
    super.initState();
    _tweets = fetchTweets(context);
  }

  Future<void> _refreshTweets() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _tweets = fetchTweets(context);
    });
  }

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

  // tweet
  Future<List<Tweet>> fetchTweets(BuildContext context) async {
    final userId = context.read<SessionBloc>().id ?? "";

    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }

    final response = await supabase.rpc('gettweet', params: {
      "search": "",
      "tag": "",
      "order_by": "created_at",
    });
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    List<Tweet> tweets = [];
    for (var tweetData in data) {
      DateTime createdAt = DateTime.parse(tweetData['created_at']);
      final userResponse = await supabase
          .from('user')
          .select('*')
          .eq('id', tweetData['creator_id'])
          .single();
      bool isReTweet = tweetData['retweet_id'] != null;
      String oriCreator = "";
      if (isReTweet) {
        final originalTweetResponse = await supabase
            .from('tweets')
            .select('*')
            .eq('id', tweetData['retweet_id'])
            .single();
        final originalCreatorResponse = await supabase
            .from('user')
            .select('display_name')
            .eq('id', originalTweetResponse['creator_id'])
            .single();
        oriCreator = originalCreatorResponse['display_name'];
      } else {
        // final response2 = "";
      }
      final retweetCountResponse = await supabase
          .from('tweets')
          .select()
          .eq('retweet_id', tweetData['id'])
          .eq('creator_id', userId);

      int retweetCount = retweetCountResponse.length;

      bool isRetweetedByUser = false;
      if (retweetCount > 0) {
        isRetweetedByUser = true;
      }

      tweets.add(Tweet(
          id: tweetData['id'],
          username: userResponse['display_name'],
          profilePicture: userResponse['display_photo'],
          verified: false,
          createdAt: timeAgo(createdAt),
          content: tweetData['content'],
          media: tweetData['media'] != null
              ? List<String>.from(
                  tweetData['media'].map((item) => item as String))
              : [],
          like: tweetData['like'],
          retweet: tweetData['retweet'],
          comment: tweetData['comment'],
          view: 100,
          isLiked: likedTweetIds.contains(tweetData['id']),
          isReTweet: isReTweet,
          oriCreator: oriCreator,
          isRetweetedByUser: isRetweetedByUser));
    }

    return tweets;
  }

  Future<String?> getDisplayPhoto(BuildContext context) async {
    try {
      final userId = context.read<SessionBloc>().id ?? "";

      final response = await supabase
          .from('user')
          .select('display_photo')
          .eq('id', userId)
          .single();
      return response['display_photo'];
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<SessionBloc>().displayName ?? "";
    Brightness theme = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text(
              "PCUFess",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            floating: true,
            pinned: true,
            leading: Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FutureBuilder<String?>(
                    future: getDisplayPhoto(context),
                    builder: (context, snapshot) {
                      Widget displayImage;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        displayImage = Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 32,
                          color: (theme == Brightness.light
                              ? Colors.black
                              : Colors.white),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        displayImage = Image.network(
                          snapshot.data!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            CupertinoIcons.person_crop_circle_fill,
                            size: 32,
                            color: (theme == Brightness.light
                                ? Colors.black
                                : Colors.white),
                          ),
                        );
                      } else {
                        displayImage = Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 32,
                          color: (theme == Brightness.light
                              ? Colors.black
                              : Colors.white),
                        );
                      }

                      return IconButton(
                        icon: ClipOval(child: displayImage),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                );
              },
            ),
            // actions: [
            //   ClipRRect(
            //     borderRadius: BorderRadius.circular(50),
            //     child: IconButton(
            //       icon: const Icon(CupertinoIcons.gear, size: 28),
            //       onPressed: () {},
            //     ),
            //   ),
            // ],
            backgroundColor: theme == Brightness.light
                ? Colors.white.withAlpha(200)
                : Colors.black.withAlpha(300),
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
          CupertinoSliverRefreshControl(
            onRefresh: _refreshTweets,
            refreshIndicatorExtent: 100,
            refreshTriggerPullDistance: 100,
            builder: (
              context,
              refreshIndicatorExtent,
              refreshTriggerPullDistance,
              pulledExtent,
              refreshState,
            ) {
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                return Center(
                  child: CupertinoActivityIndicator(
                    radius: 14.0,
                    key: Key('refresh-indicator'),
                    animating: true,
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Tweet>>(
              future: _tweets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        radius: 14,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('You are not connected to the internet'));
                  ;
                } else if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No tweets found.'));
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: snapshot.data!.map((tweet) {
                        return tweet.username == userName
                            ? Dismissible(
                                key: Key(tweet.id),
                                background: Container(
                                  // padding: EdgeInsets.only(bottom: 16),
                                  color: Colors.red,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  setState(() {
                                    snapshot.data!.remove(tweet);
                                  });
                                  await supabase.rpc(params: {
                                    "v_id": tweet.id,
                                  }, 'deletetweet');
                                  if (tweet.media.isNotEmpty) {
                                    await supabase.storage
                                        .from('tweet_medias')
                                        .remove(tweet.media);
                                  }
                                },
                                child: SingleTweet(
                                  tweet: tweet,
                                  isBookmarked: true,
                                  isLast: false,
                                  isLiked: tweet.isLiked,
                                  searchTerm: '',
                                ),
                              )
                            : SingleTweet(
                                tweet: tweet,
                                isBookmarked: true,
                                isLast: false,
                                isLiked: tweet.isLiked,
                                searchTerm: '',
                              );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(),
      drawer: MyDrawer(),
    );
  }
}
