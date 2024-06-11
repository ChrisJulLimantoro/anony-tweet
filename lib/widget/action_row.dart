import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/bookmark_button.dart';
import 'package:anony_tweet/widget/like_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.tweet,
  });

  final Tweet tweet;

  void _showBottomSheet(BuildContext context) {
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
                title:
                    Text('Repost', style: TextStyle(color: Colors.black)),
                onTap: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
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
                goToDetailPage(context, tweet.id);
              },
              child: const Icon(
                CupertinoIcons.chat_bubble,
                color: Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(width: 5),
            Text(tweet.comment.toString()),
          ],
        ),
        const SizedBox(width: 5),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                _showBottomSheet(context);
              },
              child: Icon(
                CupertinoIcons.repeat,
                color: tweet.isReTweet ? Colors.teal[400] : Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tweet.retweet.toString(),
              style: TextStyle(
                  color: tweet.isReTweet ? Colors.teal[400] : Colors.black),
            ),
          ],
        ),
        const SizedBox(width: 5),
        LikeButton(
          tweet: tweet,
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
            Text(tweet.view.toString()),
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
