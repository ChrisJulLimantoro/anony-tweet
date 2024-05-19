import 'dart:math';
import 'dart:ui';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final faker = Faker();

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    debugPrint("build");
    List<Tweet> tweets = List.generate(10, (index) {
      return Tweet(
        username: faker.internet.userName(),
        profilePicture: faker.image.image(
          keywords: ['nature', 'mountain', 'waterfall'],
          random: true,
        ),
        verified: Random().nextDouble() <= 0.5 ? true : false,
        createdAt: "${Random().nextInt(23)}h ago",
        content:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              "PCUFess",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            floating: true,
            leading: Padding(
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
                    debugPrint("PRESSED");
                  },
                ),
              ),
            ),
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
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: tweets
                      .mapIndexed(
                        (index, tweet) => SingleTweet(
                          tweet: tweet,
                          isBookmarked:
                              Random().nextDouble() <= 0.5 ? true : false,
                          isLast: index == tweets.length - 1 ? true : false,
                          isLiked: Random().nextDouble() <= 0.5 ? true : false,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64.0),
        child: FloatingActionButton(
          elevation: 1,
          onPressed: () {
            debugPrint("PRESSED");
          },
          backgroundColor: Colors.black,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
