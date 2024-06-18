import 'dart:math';
import 'dart:ui';
import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/model/notificationModel.dart';
import 'package:anony_tweet/widget/custom_fab.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:anony_tweet/widget/notification_part.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String timeAgo(String timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(DateTime.parse(timestamp));

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

  Future<List<Map<String, dynamic>>> getNotification(
      BuildContext context) async {
    final userId = context.read<SessionBloc>().id ?? "";

    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }

    // Execute the stored procedure
    final response =
        await supabase.rpc('getnotification', params: {'v_user_id': userId});

    debugPrint("response ${response.toString()}");
    // Parse the response into a list of NotificationPair objects
    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);
    debugPrint("data ${data.toString()}");
    return data.map((e) {
      e['liked'] = likedTweetIds.contains(e['tweet']['id']);
      return e;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
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
            leading: Builder(builder: (BuildContext context) {
              return Padding(
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
                      Scaffold.of(context).openDrawer();
                      debugPrint("PRESSED");
                    },
                  ),
                ),
              );
            }),
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getNotification(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Notification found.'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: snapshot.data!.map((notification) {
                            debugPrint(
                                "notification ${notification.toString()}");
                            if (notification['label'] == "comment") {
                              return SingleTweet(
                                tweet: Tweet(
                                    id: notification['tweet']['id'],
                                    username: notification['display_name'],
                                    profilePicture: notification['profile'],
                                    verified: false,
                                    createdAt:
                                        timeAgo(notification['created_at']),
                                    content: notification['tweet']['content'],
                                    media: notification['tweet']['media'] !=
                                            null
                                        ? List<String>.from(
                                            notification['tweet']['media']
                                                .map((item) => item as String))
                                        : [],
                                    like: notification['tweet']['like'],
                                    retweet: notification['tweet']['retweet'],
                                    comment: notification['tweet']['comment'],
                                    view: 0,
                                    isLiked: notification['liked'],
                                    isReTweet: false,
                                    isComment: true,
                                    oriCreator: "dummy",
                                    isRetweetedByUser: false),
                                isBookmarked: true,
                                isLast: false,
                                isLiked: notification['liked'],
                                searchTerm: '',
                              );
                            } else {
                              return NotificationPart(
                                  tweet: Tweet(
                                      id: notification['tweet']['id'],
                                      username: notification['display_name'],
                                      profilePicture: notification['profile'],
                                      verified: false,
                                      createdAt:
                                          timeAgo(notification['created_at']),
                                      content: notification['tweet']['content'],
                                      media: notification['tweet']['media'] !=
                                              null
                                          ? List<String>.from(
                                              notification['tweet']['media']
                                                  .map(
                                                      (item) => item as String))
                                          : [],
                                      like: notification['tweet']['like'],
                                      retweet: notification['tweet']['retweet'],
                                      comment: notification['tweet']['comment'],
                                      view: 0,
                                      isLiked: notification['liked'],
                                      isReTweet:
                                          notification['label'] == 'retweet',
                                      isComment: false,
                                      oriCreator: "dummy",
                                      isRetweetedByUser: false),
                                  action: notification['label'],
                                  isLast: false,
                                  searchTerm: "");
                            }
                          }).toList(),
                        ),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
