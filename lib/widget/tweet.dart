import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore_for_file: prefer_const_constructors

class Tweet extends StatefulWidget {
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
  bool isBookmarked;
  bool isLiked;
  bool isLast;

  Tweet({
    super.key,
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
    required this.isBookmarked,
    required this.isLast,
    required this.isLiked,
  });

  @override
  State<Tweet> createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
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
                    widget.profilePicture,
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
                          Text(widget.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18.0,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.createdAt,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12.0),
                          )
                        ],
                      ),
                      Text(
                        widget.content,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      if (widget.media.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ListView(
                              clipBehavior: Clip.none,
                              physics: PageScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: widget.media.map((e) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              debugPrint("tapped");
                            },
                            child: Icon(
                              CupertinoIcons.chat_bubble,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(widget.comment.toString()),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              debugPrint("tapped");
                            },
                            child: Icon(
                              CupertinoIcons.repeat,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(widget.retweet.toString()),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.isLiked = !widget.isLiked;
                                widget.like = widget.isLiked
                                    ? widget.like + 1
                                    : widget.like - 1;
                              });
                            },
                            child: Icon(
                              widget.isLiked
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: widget.isLiked ? Colors.red : Colors.grey,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(widget.like.toString()),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              debugPrint("tapped");
                            },
                            child: Icon(
                              CupertinoIcons.chart_bar_alt_fill,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(widget.view.toString()),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.isBookmarked = !widget.isBookmarked;
                              });
                            },
                            child: Icon(
                              widget.isBookmarked
                                  ? CupertinoIcons.bookmark_fill
                                  : CupertinoIcons.bookmark,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              debugPrint("tapped");
                            },
                            child: Icon(
                              CupertinoIcons.share,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isLast)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(
                height: 0.1,
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.grey.shade300
                    : Colors.grey.shade800,
              ),
            ),
        ],
      ),
    );
  }
}
