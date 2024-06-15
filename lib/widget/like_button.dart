// import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({super.key, required this.tweet});
  final Tweet tweet;

  @override
  Widget build(BuildContext context) {
    // String userId = "455cb4a8-f014-4c1e-b394-0d6a05db3fdf";
    final userId = context.read<SessionBloc>().id ?? "";
    return BlocProvider(
      create: (_) => LikeButtonBloc(
          likeCount: tweet.like,
          isLiked: tweet.isLiked,
          userId: userId,
          tweetId: tweet.id),
      child: BlocConsumer<LikeButtonBloc, List>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              context.read<LikeButtonBloc>().toggle();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state[1] ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: state[1] ? Colors.red : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text("${state[0]}",
                    style: TextStyle(
                        color: tweet.isLiked ? Colors.red : Colors.black)),
              ],
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}
