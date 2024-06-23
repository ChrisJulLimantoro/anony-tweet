import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/like_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActionRow extends StatefulWidget {
  bool isCarousel;
  final Tweet tweet;

  ActionRow({
    super.key,
    required this.tweet,
    this.isCarousel = false,
  });

  @override
  State<ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<ActionRow> {
  final supabase = Supabase.instance.client;
  late bool isRetweeted;
  late int retweetCount;

  @override
  void initState() {
    super.initState();
    isRetweeted = widget.tweet.isRetweetedByUser;
    retweetCount = widget.tweet.retweet;
  }

  void _showBottomSheet(BuildContext context, String creator, String oldId) {
    final theme = MediaQuery.of(context).platformBrightness;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme == Brightness.dark ? Colors.black : Colors.white,
      builder: (context) {
        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: theme == Brightness.dark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  CupertinoIcons.repeat,
                  color: theme == Brightness.dark ? Colors.white : Colors.black,
                ),
                title: Text(
                  isRetweeted ? 'Unrepost' : 'Repost',
                  style: TextStyle(
                    color:
                        theme == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  if (isRetweeted) {
                    unretweet(
                        widget.tweet.id, context.read<SessionBloc>().id ?? "");
                  } else {
                    retweet(creator, oldId);
                  }

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.clear_circled,
                  color: Colors.red,
                ),
                title: const Text('Cancel',
                    style: TextStyle(
                      color: Colors.red,
                    )),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void unretweet(String tweetID, String creatorID) async {
    try {
      var response = await supabase.rpc('unretweet', params: {
        'original_tweet_id': tweetID,
        'session_creator_id': creatorID
      });

      debugPrint(response);
      setState(() {
        isRetweeted = false;
        retweetCount -= 1;
      });
      debugPrint('unretweet successful');
    } catch (error) {
      debugPrint('Error unretweet tweet: $error');
    }
  }

  void retweet(String creator, String oldId) async {
    try {
      var response = await supabase
          .rpc('retweet', params: {'creator': creator, 'old_id': oldId});

      debugPrint(response);
      setState(() {
        isRetweeted = true;
        retweetCount += 1;
      });
      debugPrint('Repost successful');
    } catch (error) {
      debugPrint('Error reposting tweet: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<SessionBloc>().id ?? "";
    void goToDetailPage(BuildContext context, String detailId) {
      Navigator.pushNamed(
        context,
        '/comment',
        arguments: detailId,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                goToDetailPage(context, widget.tweet.id);
              },
              child: const Icon(
                CupertinoIcons.chat_bubble,
                color: Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(width: 5),
            Text(widget.tweet.comment.toString(),
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(width: 5),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                _showBottomSheet(context, userId, widget.tweet.id);
              },
              child: Icon(
                CupertinoIcons.repeat,
                color: isRetweeted ? Colors.teal[400] : Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              retweetCount.toString(),
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(width: 5),
        LikeButton(tweet: widget.tweet, isCarousel: widget.isCarousel),
      ],
    );
  }
}
