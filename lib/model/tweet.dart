import 'package:anony_tweet/main.dart';
import 'package:faker/faker.dart';

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
  bool isReTweet;

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
    required this.isLiked,
    required this.isReTweet,
  });
}
