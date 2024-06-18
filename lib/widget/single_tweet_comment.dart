// import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/bookmark_bloc.dart';
import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:anony_tweet/model/tweet.dart';
// import 'package:anony_tweet/widget/action_row.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool isRetweeted = false;
  int retweetCount = 0;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    isBookmarked = widget.isBookmarked;
    like = widget.tweet.like;
    bookmark = widget.tweet.view;
    isRetweeted = widget.tweet.isRetweetedByUser;
    retweetCount = widget.tweet.retweet;
    print(isRetweeted);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> handleRetweetOperation(String userId) async {
    try {
      if (isRetweeted) {
        var response = await Supabase.instance.client.rpc('unretweet', params: {
          'original_tweet_id': widget.tweet.id,
          'session_creator_id': userId
        });

        setState(() {
          isRetweeted = false;
          retweetCount -= 1;
        });
      } else {
        var response = await Supabase.instance.client.rpc('retweet',
            params: {'creator': userId, 'old_id': widget.tweet.id});
        print(response);
        setState(() {
          isRetweeted = true;
          retweetCount += 1;
        });
      }

      debugPrint('Retweet operation successful');
    } catch (e) {
      debugPrint('Error performing retweet operation: $e');
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  CupertinoIcons.arrow_2_squarepath,
                  color: Colors.black,
                ),
                title: Text(
                  isRetweeted ? 'Unrepost' : 'Repost',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  // Toggle retweet status
                  handleRetweetOperation(context.read<SessionBloc>().id ?? "");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.clear_circled,
                  color: Colors.red,
                ),
                title:
                    const Text('Cancel', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
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

  Future<void> handleLikeOperation(String userId) async {
    if (isLiked) {
      isLiked = false;
      like--;
      await Supabase.instance.client.from('likes').delete().match({
        'user_id': userId,
        'tweet_id': widget.tweet.id,
      });
    } else {
      isLiked = true;
      like++;
      await Supabase.instance.client.from('likes').insert({
        'user_id': userId,
        'tweet_id': widget.tweet.id,
      });
    }
    // Update the state only after the async operation is complete
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final userId = context.read<SessionBloc>().id ?? "";
    // debugPrint(widget.tweet.verified.toString());
    return MultiBlocProvider(
      providers: [
        BlocProvider<LikeButtonBloc>(
            create: (context) => LikeButtonBloc(
                likeCount: widget.tweet.like,
                isLiked: widget.tweet.isLiked,
                userId: userId,
                tweetId: widget.tweet.id)),
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
                        searchTerm: '',
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
                    Text(widget.tweet.createdAt,
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
                      retweetCount.toString(),
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
                      onPressed: () => handleLikeOperation(userId),
                      icon: Icon(
                        isLiked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_2_squarepath,
                        color: isRetweeted ? Colors.teal[400] : Colors.grey,
                      ),
                      onPressed: () => _showBottomSheet(context),
                    )
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
