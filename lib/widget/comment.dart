import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/screen/search.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/like_button.dart';
import 'package:anony_tweet/widget/tweet_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore_for_file: prefer_const_constructors

class Comment extends StatefulWidget {
  final Tweet tweet;
  final bool isLast;
  final bool isBookmarked;
  final bool isLiked;
  final String searchTerm;

  const Comment({
    super.key,
    required this.tweet,
    required this.isLast,
    required this.isBookmarked,
    required this.isLiked,
    required this.searchTerm,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool isLiked = false;
  bool isBookmarked = false;
  int like = 0;
  int retweet = 0;
  bool isReTweet = false;
  @override
  void initState() {
    super.initState();
    isLiked = widget.tweet.isLiked;
    like = widget.tweet.like;
    retweet = widget.tweet.retweet;
    isBookmarked = widget.isBookmarked;
    isReTweet = widget.tweet.isRetweetedByUser;
    // print(isLiked);
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

  Future<void> handleRetweetOperation(String userId) async {
    try {
      if (isReTweet) {
        var response = await Supabase.instance.client.rpc('unretweet', params: {
          'original_tweet_id': widget.tweet.id,
          'session_creator_id': userId
        });

        setState(() {
          isReTweet = false;
          retweet -= 1;
        });
      } else {
        var response = await Supabase.instance.client.rpc('retweet',
            params: {'creator': userId, 'old_id': widget.tweet.id});
        print(response);
        setState(() {
          isReTweet = true;
          retweet += 1;
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
                  isReTweet ? 'Unrepost' : 'Repost',
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

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final userId = context.read<SessionBloc>().id ?? "";

    void goToDetailPage(BuildContext context, String detailId) {
      Navigator.pushNamed(
        context,
        '/comment',
        arguments: detailId,
      );
    }

    // debugPrint(widget.tweet.verified.toString());
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
                    HashtagText(
                      text: widget.tweet.content,
                      searchTerm: widget.searchTerm,
                      onTagTap: (String tag) {
                        Navigator.pushNamed(
                          context,
                          '/search',
                          arguments: tag,
                        );
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (widget.tweet.media.isNotEmpty)
                      TweetMediaGrid(
                          tweet: widget.tweet, images: widget.tweet.media),
                      // SizedBox(
                      //   height: 200,
                      //   width: widget.tweet.media.length * 200.0 >
                      //           MediaQuery.of(context).size.width
                      //       ? MediaQuery.of(context).size.width
                      //       : widget.tweet.media.length * 200.0,
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(10),
                      //     child: ListView(
                      //       clipBehavior: Clip.none,
                      //       physics: PageScrollPhysics(),
                      //       scrollDirection: Axis.horizontal,
                      //       children: widget.tweet.media.map((e) {
                      //         return Container(
                      //           decoration: BoxDecoration(
                      //               border: Border(
                      //                   right: BorderSide(
                      //                       color: MediaQuery.of(context)
                      //                                   .platformBrightness ==
                      //                               Brightness.light
                      //                           ? Colors.white
                      //                           : Colors.black,
                      //                       width: 2))),
                      //           child: Image.network(
                      //             getImageUrl("tweet_medias", e),
                      //             height: 200,
                      //             width: 200,
                      //             fit: BoxFit.cover,
                      //           ),
                      //         );
                      //       }).toList(),
                      //     ),
                      //   ),
                      // ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            goToDetailPage(context, widget.tweet.id);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.chat_bubble_2,
                                color: Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.tweet.comment.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            handleLikeOperation(userId);
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
                                like.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.repeat,
                                color:
                                    isReTweet ? Colors.teal[400] : Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                retweet.toString(),
                                style: TextStyle(fontSize: 12),
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
