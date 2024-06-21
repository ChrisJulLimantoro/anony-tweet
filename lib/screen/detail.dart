import 'dart:math';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/comment.dart';
import 'package:anony_tweet/widget/single_tweet_comment.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.id});
  final String id;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Tweet> tweet;
  @override
  void initState() {
    super.initState();
  }

  String customTimeStamp(DateTime timestamp) {
    DateTime localDateTime = timestamp.toLocal();
    DateFormat formatter = DateFormat("hh:mm a · MMMM dd, yyyy");
    String formatted = formatter.format(localDateTime);
    return formatted;
  }

  Future<Tweet> fetchTweet(String id, BuildContext context) async {
    final userId = context.read<SessionBloc>().id ?? "";
    final likedTweetsResponse = await Supabase.instance.client
        .from('likes')
        .select('tweet_id')
        .eq('user_id', userId);
    final likedTweetIds = <String>{};
    // if (likedTweetsResponse != null) {
    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }
    // }
    // print(likedTweetsResponse);
    final response = await Supabase.instance.client
        .from('tweets')
        .select('*')
        .eq('id', id)
        .single();
    // print(response);

    final userResponse = await Supabase.instance.client
        .from('user')
        .select('*')
        .eq('id', response['creator_id'])
        .single();
    DateTime createdAt = DateTime.parse(response['created_at']);
    // print("result: ${likedTweetIds.contains(response['id'])}");
    final retweetCountResponse = await Supabase.instance.client
        .from('tweets')
        .select()
        .eq('retweet_id', response['id'])
        .eq('creator_id', userId);

    int retweetCount = retweetCountResponse.length;
    print(retweetCount);

    bool isRetweetedByUser = false;
    if (retweetCount > 0) {
      isRetweetedByUser = true;
    }
    bool isReTweet = response['retweet_id'] != null;
    String oriCreator = "";
    if (isReTweet) {
      final originalTweetResponse = await Supabase.instance.client
          .from('tweets')
          .select('*')
          .eq('id', response['retweet_id'])
          .single();
      final originalCreatorResponse = await Supabase.instance.client
          .from('user')
          .select('display_name')
          .eq('id', originalTweetResponse['creator_id'])
          .single();
      oriCreator = originalCreatorResponse['display_name'];
    } else {
      final response2 = "";
    }
    return Tweet(
        id: response['id'],
        username: userResponse['display_name'],
        profilePicture: userResponse['display_photo'],
        verified: Random().nextBool(),
        createdAt: customTimeStamp(createdAt),
        content: response['content'],
        media: response['media'] != null
            ? List<String>.from(response['media'].map((item) => item as String))
            : [],
        like: response['like'],
        retweet: response['retweet'],
        comment: response['comment'],
        view: 100,
        isLiked: likedTweetIds.contains(response['id']),
        isReTweet: isReTweet,
        oriCreator: oriCreator,
        isRetweetedByUser: isRetweetedByUser);
  }

  List<Tweet> tweets = List.generate(10, (index) {
    return Tweet(
        id: '1',
        username: faker.internet.userName(),
        profilePicture: "https://randomuser.me/api/portraits/women/18.jpg",
        verified: Random().nextDouble() <= 0.5 ? true : false,
        createdAt: "${Random().nextInt(23)}h ago",
        content: "saya punya babi #anjing #leo",
        media: [],
        like: Random().nextInt(1000),
        retweet: Random().nextInt(1000),
        comment: Random().nextInt(1000),
        view: Random().nextInt(900) + 100,
        isReTweet: Random().nextBool(),
        isLiked: Random().nextBool(),
        oriCreator: "Dummy",
        isRetweetedByUser: false);
  });

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

  Future<List<Tweet>> fetchComments(String id) async {
    final userId = context.read<SessionBloc>().id ?? "";
    final response = await Supabase.instance.client
        .rpc('getcomment', params: {'idtweets': id});

    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
    debugPrint("data ${data.toString()}");
    List<Tweet> comments = [];
    final likedTweetsResponse = await Supabase.instance.client
        .from('likes')
        .select('tweet_id')
        .eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }

    for (var commentData in data) {
      DateTime createdAt = DateTime.parse(commentData['created_at']);
      final userResponse = await Supabase.instance.client
          .from('user')
          .select('*')
          .eq('id', commentData['creator_id'])
          .single();
      bool isReTweet = commentData['retweet_id'] != null;
      String oriCreator = "";
      if (isReTweet) {
        final originalTweetResponse = await Supabase.instance.client
            .from('tweets')
            .select('*')
            .eq('id', commentData['retweet_id'])
            .single();
        final originalCreatorResponse = await Supabase.instance.client
            .from('user')
            .select('display_name')
            .eq('id', originalTweetResponse['creator_id'])
            .single();
        oriCreator = originalCreatorResponse['display_name'];
      } else {
        final response2 = "";
      }

      final retweetCountResponse = await Supabase.instance.client
          .from('tweets')
          .select()
          .eq('retweet_id', commentData['id'])
          .eq('creator_id', userId);

      int retweetCount = retweetCountResponse.length;
      bool isRetweetedByUser = false;
      if (retweetCount > 0) {
        isRetweetedByUser = true;
      }
      comments.add(Tweet(
          id: commentData['id'],
          username: userResponse['display_name'],
          profilePicture: userResponse['display_photo'],
          verified: false,
          createdAt: timeAgo(createdAt),
          content: commentData['content'],
          media: commentData['media'] != null
              ? List<String>.from(
                  commentData['media'].map((item) => item as String))
              : [],
          like: commentData['like'],
          retweet: commentData['retweet'],
          comment: commentData['comment'],
          view: 100,
          isLiked: likedTweetIds.contains(commentData['id']),
          isReTweet: isReTweet,
          oriCreator: oriCreator,
          isRetweetedByUser: isRetweetedByUser));
    }
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: const Text(
              "Post",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            centerTitle: true,
            floating: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ClipRRect(
                child: IconButton(
                  icon: const Icon(
                    CupertinoIcons.arrow_left,
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.pop(context, '/home');
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Tweet>(
                        future: fetchTweet(widget.id, context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center();
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleTweetComment(
                                    
                                    tweet: snapshot.data!,
                                    isBookmarked: Random().nextDouble() <= 0.5,
                                    isLast: false,
                                    isLiked: snapshot.data!.isLiked,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(child: Text("No tweet found."));
                          }
                        }),
                    Column(
                      children: [
                        FutureBuilder<List<Tweet>>(
                          future: fetchComments(widget
                              .id), // Assuming widget.id is the tweet's ID
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              print(snapshot);
                              return Column(
                                children: snapshot.data!.map((tweet) {
                                  int index = snapshot.data!.indexOf(tweet);
                                  return index == 0
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Comment(
                                            tweet: tweet,
                                            isBookmarked: Random().nextBool(),
                                            isLiked: Random().nextBool(),
                                            isLast: index ==
                                                snapshot.data!.length - 1,
                                          ),
                                        )
                                      : Comment(
                                          tweet: tweet,
                                          isBookmarked: Random().nextBool(),
                                          isLiked: Random().nextBool(),
                                          isLast: index ==
                                              snapshot.data!.length - 1,
                                        );
                                }).toList(),
                              );
                            } else {
                              print("hello");
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: Text("No comments found.",
                                      textAlign: TextAlign.center),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
