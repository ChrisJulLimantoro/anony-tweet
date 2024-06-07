import 'dart:math';

import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet_comment.dart';
import 'package:anony_tweet/widget/single_tweet_reply.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class PostComment extends StatelessWidget {
  const PostComment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 5),
        //   child: Center(child: Text("Cancel", style: TextStyle(fontSize: 16),)),
        // ),
        title: TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          onPressed: () {
            Navigator.popAndPushNamed(context, "/comment");
          },
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                "Post",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                SingleTweetReply(
                  tweet: Tweet(
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
                    isLiked: Random().nextBool(),
                    isReTweet: Random().nextBool()
                  ),
                  isBookmarked: Random().nextDouble() <= 0.5 ? true : false,
                  isLast: false,
                  isLiked: Random().nextDouble() <= 0.5 ? true : false,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        faker.image.image(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Post your reply",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        ),
                        style: TextStyle(fontSize: 16),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
