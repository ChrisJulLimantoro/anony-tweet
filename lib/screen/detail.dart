import 'dart:math';

import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/comment.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:anony_tweet/widget/single_tweet_comment.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Tweet> tweets = List.generate(10, (index) {
    return Tweet(
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
    );
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
                    SingleTweetComment(
                      tweet: Tweet(
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
                      ),
                      isBookmarked: Random().nextDouble() <= 0.5 ? true : false,
                      isLast: false,
                      isLiked: Random().nextDouble() <= 0.5 ? true : false,
                    ),
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
