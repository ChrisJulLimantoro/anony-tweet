import 'dart:ui';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/widget/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:anony_tweet/widget/notification_part.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = getNotification(context);
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notificationsFuture = getNotification(context);
    });
  }

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

  Future<String?> getDisplayPhoto(BuildContext context) async {
    try {
      final userId = context.read<SessionBloc>().id ?? "";

      final response = await supabase
          .from('user')
          .select('display_photo')
          .eq('id', userId)
          .single();
      return response['display_photo'];
    } catch (e) {
      return null;
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

    // Parse the response into a list of NotificationPair objects
    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);
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
        // physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text(
              "PCUFess",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            floating: true,
            pinned: true,
            leading: Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FutureBuilder<String?>(
                    future: getDisplayPhoto(context),
                    builder: (context, snapshot) {
                      Widget displayImage;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        displayImage = Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 32,
                          color: (theme == Brightness.light
                              ? Colors.black
                              : Colors.white),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        displayImage = Image.network(
                          snapshot.data!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            CupertinoIcons.person_crop_circle_fill,
                            size: 32,
                            color: (theme == Brightness.light
                                ? Colors.black
                                : Colors.white),
                          ),
                        );
                      } else {
                        displayImage = Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 32,
                          color: (theme == Brightness.light
                              ? Colors.black
                              : Colors.white),
                        );
                      }

                      return IconButton(
                        icon: ClipOval(child: displayImage),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                );
              },
            ),
            // actions: [
            //   ClipRRect(
            //     borderRadius: BorderRadius.circular(50),
            //     child: IconButton(
            //       icon: const Icon(CupertinoIcons.gear, size: 28),
            //       onPressed: () {},
            //     ),
            //   ),
            // ],
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
          CupertinoSliverRefreshControl(
            onRefresh: _refreshNotifications,
            refreshIndicatorExtent: 100,
            refreshTriggerPullDistance: 100,
            builder: (
              context,
              refreshIndicatorExtent,
              refreshTriggerPullDistance,
              pulledExtent,
              refreshState,
            ) {
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                return const Center(
                  child: CupertinoActivityIndicator(
                    radius: 14.0,
                    key: Key('refresh-indicator'),
                    animating: true,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        radius: 14,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('You are not connected to the internet.'));
                } else if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Notification found.'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: snapshot.data!.map((notification) {
                        void openDetail(String id) {
                          Navigator.pushNamed(
                            context,
                            '/comment',
                            arguments: id,
                          );
                        }

                        Tweet tweet = Tweet(
                          id: notification['tweet']['id'],
                          username: notification['display_name'],
                          profilePicture: notification['profile'],
                          verified: false,
                          createdAt: timeAgo(notification['created_at']),
                          content: notification['tweet']['content'],
                          media: notification['tweet']['media'] != null
                              ? List<String>.from(notification['tweet']['media']
                                  .map((item) => item as String))
                              : [],
                          like: notification['tweet']['like'],
                          retweet: notification['tweet']['retweet'],
                          comment: notification['tweet']['comment'],
                          view: 0,
                          isLiked: notification['liked'],
                          isReTweet: notification['label'] == 'retweet',
                          isComment: false,
                          oriCreator: "",
                          isRetweetedByUser: notification['label'] == 'retweet',
                        );

                        if (notification['label'] == "comment") {
                          return GestureDetector(
                            onTap: () => openDetail(tweet.id),
                            child: SingleTweet(
                              tweet: tweet,
                              isBookmarked: true,
                              isLast: false,
                              isLiked: notification['liked'],
                              searchTerm: '',
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => openDetail(tweet.id),
                            child: NotificationPart(
                              tweet: tweet,
                              action: notification['label'],
                              isLast: false,
                              searchTerm: "",
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
