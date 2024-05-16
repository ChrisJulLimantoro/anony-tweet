import 'dart:math';

import 'package:anony_tweet/widget/tweet.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final faker = Faker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCUFess'),
      ),
      body: ListView(
        children: [
          Tweet(
            username: faker.internet.userName(),
            profilePicture: faker.image.image(
              keywords: ['nature', 'mountain', 'waterfall'],
              random: true,
            ),
            verified: true,
            createdAt: "8h ago",
            content:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
            media: List.generate(
                Random().nextInt(4) + 2,
                (index) => faker.image.image(
                      keywords: ['nature', 'mountain', 'waterfall'],
                      height: 200,
                      width: 200,
                      random: true,
                    )),
            like: 100,
            retweet: 50,
            comment: 20,
            view: 1000,
            isBookmarked: true,
            isLast: false,
            isLiked: true,
          ),
          Tweet(
            username: faker.internet.userName(),
            profilePicture: faker.image.image(
              keywords: ['nature', 'mountain', 'waterfall'],
              random: true,
            ),
            verified: true,
            createdAt: "8h ago",
            content:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
            media: List.generate(
                Random().nextInt(4) + 2,
                (index) => faker.image.image(
                      keywords: ['nature', 'mountain', 'waterfall'],
                      height: 200,
                      width: 200,
                      random: true,
                    )),
            like: 100,
            retweet: 50,
            comment: 20,
            view: 1000,
            isBookmarked: false,
            isLast: true,
            isLiked: false,
          ),
        ],
      ),
    );
  }
}
