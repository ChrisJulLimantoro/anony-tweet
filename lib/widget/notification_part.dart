import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/bookmark_bloc.dart';
import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/screen/search.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/tweet_media.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore_for_file: prefer_const_constructors

class NotificationPart extends StatelessWidget {
  final Tweet tweet;
  final String action;
  final bool isLast;
  final String searchTerm;

  const NotificationPart({
    super.key,
    required this.tweet,
    required this.action,
    required this.isLast,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final userId = context.read<SessionBloc>().id ?? "";
    // debugPrint(tweet.verified.toString());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              action == 'retweet'
                  ? Icon(
                      CupertinoIcons.repeat,
                      color: Colors.teal,
                      size: 30,
                    )
                  : Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                      size: 30,
                    ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: tweet.profilePicture,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tweet.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          Text(action == 'retweet'
                              ? ' reposted your post'
                              : ' liked your post')
                        ],
                      ),
                      HashtagText(
                        text: tweet.content,
                        searchTerm: searchTerm,
                        onTagTap: (String tag) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(
                                initialSearch: tag,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      if (tweet.media.isNotEmpty)
                        TweetMediaGrid(images: tweet.media),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        !isLast
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(
                  height: 0.1,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                ),
              )
            : SizedBox(height: 150),
      ],
    );
  }
}
