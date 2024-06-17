import 'dart:io';
import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/bookmark_bloc.dart';
import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore_for_file: prefer_const_constructors

class SingleTweetReply extends StatefulWidget {
  final Tweet tweet;
  final bool isBookmarked;
  final bool isLiked;
  final bool isLast;

  const SingleTweetReply({
    super.key,
    required this.tweet,
    required this.isBookmarked,
    required this.isLast,
    required this.isLiked,
  });

  @override
  State<SingleTweetReply> createState() => _SingleTweetReplyState();
}

class _SingleTweetReplyState extends State<SingleTweetReply> {
  bool isLiked = false;
  bool isBookmarked = false;
  int like = 0;
  int bookmark = 0;
  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    isBookmarked = widget.isBookmarked;
    like = widget.tweet.like;
    bookmark = widget.tweet.view;
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<SessionBloc>().id ?? "";
    Brightness theme = MediaQuery.of(context).platformBrightness;

    // debugPrint(widget.tweet.verified.toString());
    return MultiBlocProvider(
      providers: [
        BlocProvider<LikeButtonBloc>(
          create: (context) => LikeButtonBloc(
              likeCount: widget.tweet.like,
              isLiked: widget.tweet.isLiked,
              userId: userId,
              tweetId: widget.tweet.id),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(widget.isBookmarked),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    widget.tweet.profilePicture,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.tweet.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          if (widget.tweet.verified)
                            Icon(
                              Icons.verified,
                              color: (theme == Brightness.light
                                  ? Colors.black
                                  : Colors.white),
                              size: 18.0,
                            ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                      HashtagText(
                        text: "saya punya babi #anjing #leo",
                        searchTerm: "",
                        onTagTap: (String tag) {
                          print("Tapped on $tag");
                          // You can add more actions here, like navigating to another page or showing a modal.
                        },
                      ),
                      // Text(
                      //   widget.tweet.content,
                      //   style: TextStyle(
                      //     fontSize: 16.0,
                      //   ),
                      // ),
                      SizedBox(
                        height: 8,
                      ),
                      if (widget.tweet.media.isNotEmpty)
                        SizedBox(
                          height: 200,
                          width: widget.tweet.media.length * 200.0 >
                                  MediaQuery.of(context).size.width
                              ? MediaQuery.of(context).size.width
                              : widget.tweet.media.length * 200.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ListView(
                              clipBehavior: Clip.none,
                              physics: PageScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: widget.tweet.media.map((e) {
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              color: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.white
                                                  : Colors.black,
                                              width: 2))),
                                  child: Image.network(
                                    getImageUrl("tweet_medias", e),
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Replying to "),
                            Text(
                              "@hello",
                              style: TextStyle(color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
