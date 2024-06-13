import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/bookmark_button.dart';
import 'package:anony_tweet/widget/like_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActionRow extends StatefulWidget {
  ActionRow({
    super.key,
    required this.tweet,
  });

  final Tweet tweet;

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
    isRetweeted = widget.tweet.isReTweet;
    retweetCount = widget.tweet.retweet;
  }

  void _showBottomSheet(BuildContext context, String creator, String oldId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                leading: Icon(CupertinoIcons.repeat, color: Colors.black),
                title: Text('Repost', style: TextStyle(color: Colors.black)),
                onTap: () {
                  retweet(creator, oldId);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.clear_circled, color: Colors.red),
                title: Text('Cancel', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void retweet(String creator, String oldId) async {
    try {
      var response = await supabase
          .rpc('retweet', params: {'creator': creator, 'old_id': oldId});

      print(response);
      setState(() {
        isRetweeted = true;
        retweetCount += 1;
      });
      print('Repost successful');
    } catch (error) {
      print('Error reposting tweet: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = SessionContext.of(context)!.id;
    void goToDetailPage(BuildContext context, String detailId) {
      Navigator.pushNamed(
        context,
        '/comment',
        arguments: detailId,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            Text(widget.tweet.comment.toString()),
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
                  color: isRetweeted ? Colors.teal[400] : Colors.black),
            ),
          ],
        ),
        const SizedBox(width: 5),
        LikeButton(
          tweet: widget.tweet,
        ),
        const SizedBox(width: 5),
        Row(
          children: [
            const Icon(
              CupertinoIcons.chart_bar_alt_fill,
              color: Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(widget.tweet.view.toString()),
          ],
        ),
        const SizedBox(width: 5),
        Row(
          children: [
            const BookmarkButton(),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                debugPrint("tapped");
              },
              child: const Icon(
                CupertinoIcons.share,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
