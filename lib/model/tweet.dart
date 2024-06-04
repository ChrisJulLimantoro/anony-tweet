
import 'package:faker/faker.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:flutter/cupertino.dart';

class Tweet {
  String id;
  String username;
  String profilePicture;
  bool verified;
  String createdAt;
  String content;
  List<String> media;
  int like;
  int retweet;
  int comment;
  int view;
  bool isLiked;

  Tweet({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.verified,
    required this.createdAt,
    required this.content,
    required this.media,
    required this.like,
    required this.retweet,
    required this.comment,
    required this.view,
    required this.isLiked
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    final faker = Faker();

    return Tweet(
      id: '1',
      username: 'Anonymous',
      profilePicture: faker.image.image(
        keywords: ['nature', 'mountain', 'waterfall'],
        random: true,
      ),
      verified: false,
      createdAt: json['created_at'],
      content: json['content'],
      media: json['media'] != null ? List<String>.from(json['media']) : [],
      like: json['like'],
      retweet: json['retweet'],
      comment: json['comment'],
      view: 0,
      isLiked: false
    );
  }
}
