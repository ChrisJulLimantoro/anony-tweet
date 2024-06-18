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
    return Tweet(
        id: response['id'],
        username: userResponse['display_name'],
        profilePicture: userResponse['display_photo'],
        verified: Random().nextBool(),
        createdAt: customTimeStamp(createdAt),
        content: response['content'],
        media: response['media'] != null
            ? List<String>.from(
                response['media'].map((item) => item as String))
            : [],
        like: response['like'],
        retweet: response['retweet'],
        comment: response['comment'],
        view: 100,
        isLiked: likedTweetIds.contains(response['id']),
        isReTweet: Random().nextBool());
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
        isReTweet: Random().nextBool(),
        isLiked: Random().nextBool());
  });
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
