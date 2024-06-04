import 'dart:math';

import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/comment.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:anony_tweet/widget/single_tweet_comment.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Future<Tweet> fetchTweet(String id, BuildContext context) async {
    final userId = SessionContext.of(context)!.id;
    final likedTweetsResponse = await Supabase.instance.client
        .from('likes')
        .select('tweet_id')
        .eq('user_id', userId);
    final likedTweetIds = <String>{};
    if (likedTweetsResponse != null) {
      for (var record in likedTweetsResponse) {
        likedTweetIds.add(record['tweet_id']);
      }
    }
    // print(likedTweetsResponse);
    final response = await Supabase.instance.client
        .from('tweets')
        .select('*')
        .eq('id', id)
        .single();
    // print(response);

    final userResponse = await Supabase.instance.client
        .from('user')
        .select('*') // Pastikan untuk memilih kolom yang dibutuhkan saja
        .eq('id', response['creator_id'])
        .single();
    DateTime createdAt = DateTime.parse(response['created_at']);
    // print("result: ${likedTweetIds.contains(response['id'])}");
    return Tweet(
      id: response['id'],
      username: userResponse['display_name'],
      profilePicture: userResponse['display_photo'],
      verified: Random().nextBool(),
      createdAt: timeAgo(createdAt),
      content: response['content'],
      media: [],
      like: response['like'],
      retweet: response['retweet'],
      comment: response['comment'],
      view: 100,
      isLiked: likedTweetIds.contains(response['id']),
    );
  }

  List<Tweet> tweets = List.generate(10, (index) {
    return Tweet(
        id: '1',
        username: faker.internet.userName(),
        profilePicture: faker.image.image(
          keywords: ['nature', 'mountain', 'waterfall'],
          random: true,
        ),
        verified: Random().nextDouble() <= 0.5 ? true : false,
        createdAt: "${Random().nextInt(23)}h ago",
        content: "saya punya babi #anjing #leo",
        media: List.generate(
            Random().nextInt(4),
            (index) => faker.image.image(
                  keywords: ['nature', 'mountain', 'waterfall'],
                  height: 200,
                  width: 200,
                  random: true,
                )),
        like: Random().nextInt(1000),
        retweet: Random().nextInt(1000),
        comment: Random().nextInt(1000),
        view: Random().nextInt(900) + 100,
        isLiked: Random().nextBool());
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      // appBar: AppBar(
      //   leading: Icon(Icons.arrow_back_rounded),
      //   title: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
      //   centerTitle: true,
      // ),
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
                            return Center(child: CircularProgressIndicator());
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
                      children: tweets
                          .asMap()
                          .map((index, tweet) => MapEntry(
                                index,
                                index == 0
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Comment(
                                          tweet: tweet,
                                          isBookmarked: Random().nextBool(),
                                          isLiked: Random().nextBool(),
                                          isLast: index == tweets.length - 1,
                                        ),
                                      )
                                    : Comment(
                                        tweet: tweet,
                                        isBookmarked: Random().nextBool(),
                                        isLiked: Random().nextBool(),
                                        isLast: index ==
                                            tweets.length -
                                                1, // Check if the tweet is the last one
                                      ),
                              ))
                          .values
                          .toList(),
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
