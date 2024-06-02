import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore_for_file: prefer_const_constructors

class Comment extends StatefulWidget {
  final Tweet tweet;
  final bool isLast;
  final bool isBookmarked;
  final bool isLiked;

  const Comment({
    super.key,
    required this.tweet,
    required this.isLast,
    required this.isBookmarked,
    required this.isLiked,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool isLiked = false;
  bool isBookmarked = false;
  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    isBookmarked = widget.isBookmarked;
    print(isLiked);
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    debugPrint(widget.tweet.verified.toString());
    return Column(
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
                  children: [
                    Row(
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
                        Text(
                          widget.tweet.createdAt,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12.0),
                        ),
                        // SizedBox(
                        //   // width: double.infinity,
                        //   width: 150,
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )
                        // )
                      ],
                    ),
                    Text(
                      widget.tweet.content,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("comment");
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.chat_bubble_2,
                                color: Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "900",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isLiked) {
                                isLiked = false;
                              } else {
                                isLiked = true;
                              }
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLiked
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "900",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.repeat,
                                color: Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "900",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isBookmarked) {
                                isBookmarked = false;
                              } else {
                                isBookmarked = true;
                              }
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isBookmarked
                                    ? CupertinoIcons.bookmark_fill
                                    : CupertinoIcons.bookmark,
                                color: isBookmarked
                                    ? Colors.yellow[600]
                                    : Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "900",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.share,
                                color: Colors.grey,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        !widget.isLast
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  height: 0.1,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                ),
              )
            : SizedBox(height: 10),
      ],
    );
  }
}
