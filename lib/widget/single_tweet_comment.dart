import 'dart:io';

import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/bookmark_bloc.dart';
import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore_for_file: prefer_const_constructors

class SingleTweetComment extends StatefulWidget {
  final Tweet tweet;
  final bool isBookmarked;
  final bool isLiked;
  final bool isLast;

  const SingleTweetComment({
    super.key,
    required this.tweet,
    required this.isBookmarked,
    required this.isLast,
    required this.isLiked,
  });

  @override
  State<SingleTweetComment> createState() => _SingleTweetCommentState();
}

class _SingleTweetCommentState extends State<SingleTweetComment> {
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
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final userId = SessionContext.of(context)!.id; 
    // debugPrint(widget.tweet.verified.toString());
    return MultiBlocProvider(
      providers: [
        BlocProvider<LikeButtonBloc>(
          create: (context) =>
              LikeButtonBloc(
              likeCount: widget.tweet.like,
              isLiked: widget.tweet.isLiked,
              userId: userId,
              tweetId: widget.tweet.id)
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
                        text: widget.tweet.content,
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
                                    e,
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
                        height: 8,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('8:35 PM · May 20, 2024',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 0.1,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      widget.tweet.comment.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "comment",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(width: 10),
                    Text(
                      like.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "like",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(width: 10),
                    Text(
                      bookmark.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "bookmark",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(width: 10),
                    Text(
                      widget.tweet.retweet.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "repost",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 0.1,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/postComment');
                      },
                      icon: Icon(
                        CupertinoIcons.bubble_left,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // print(widget.tweet.like);
                        //minus logic like to DB
                        setState(() {
                          if (isLiked) {
                            isLiked = false;
                            like--;
                          } else {
                            isLiked = true;
                            like++;
                          }
                        });
                      },
                      icon: Icon(
                        isLiked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.arrow_2_squarepath,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (isBookmarked) {
                            isBookmarked = false;
                            bookmark--;
                          } else {
                            isBookmarked = true;
                            bookmark++;
                          }
                        });
                      },
                      icon: Icon(
                          isBookmarked
                              ? CupertinoIcons.bookmark_fill
                              : CupertinoIcons.bookmark,
                          color:
                              isBookmarked ? Colors.yellow[600] : Colors.grey),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.share,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            height: 0.1,
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.grey.shade300
                : Colors.grey.shade800,
          ),
        ],
      ),
    );
  }
}
