import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
// import 'package:anony_tweet/screen/search.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/tweet_media.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore_for_file: prefer_const_constructors

class SingleTweet extends StatelessWidget {
  final Tweet tweet;
  final bool isBookmarked;
  final bool isLiked;
  final bool isLast;
  final String searchTerm;

  const SingleTweet({
    super.key,
    required this.tweet,
    required this.isBookmarked,
    required this.isLast,
    required this.isLiked,
    required this.searchTerm,
  });

  void goToDetailPage(BuildContext context, String detailId) {
    Navigator.pushNamed(
      context,
      '/comment',
      arguments: detailId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final userId = context.read<SessionBloc>().id ?? "";
    final userName = context.read<SessionBloc>().displayName ?? "";
    // debugPrint(tweet.verified.toString());
    return MultiBlocProvider(
      providers: [
        BlocProvider<LikeButtonBloc>(
          create: (context) => LikeButtonBloc(
            likeCount: tweet.like,
            isLiked: tweet.isLiked,
            userId: userId,
            tweetId: tweet.id,
          ),
        ),
      ],
      child: Column(
        children: [
          tweet.isReTweet
              ? Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 32, top: 16),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.repeat,
                            size: 12,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Reposted from ${tweet.oriCreator}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 0,
                ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: tweet.profilePicture,
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
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(tweet.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  if (tweet.verified)
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
                                    tweet.createdAt,
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12.0),
                                  ),
                                ],
                              ),
                              tweet.isComment
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Replying to ",
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        GestureDetector(
                                          child: Text(
                                            'this post',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.blue,
                                            ),
                                          ),
                                          onTap: () {
                                            goToDetailPage(
                                                context, tweet.commentId!);
                                          },
                                        )
                                      ],
                                    )
                                  : SizedBox(height: 0),
                            ],
                          ),
                          // Spacer(),
                          // if (tweet.username == userName)
                          //   IconButton(
                          //     icon: Icon(Icons.close, color: Colors.red),
                          //     onPressed: () async {
                          //       // print(tweet.id);
                          //       await supabase.rpc('deletetweet',
                          //           params: {'v_id': tweet.id});
                          //     },
                          //   ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: HashtagText(
                          text: tweet.content,
                          searchTerm: searchTerm,
                          onTagTap: (String tag) {
                            Navigator.pushNamed(
                              context,
                              '/search',
                              arguments: tag,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      if (tweet.media.isNotEmpty)
                        TweetMediaGrid(
                          tweet: tweet,
                          images: tweet.media,
                        ),
                      SizedBox(
                        height: 8,
                      ),
                      ActionRow(tweet: tweet),
                    ],
                  ),
                ),
              ],
            ),
          ),
          !isLast
              ? Divider(
                  height: 0.1,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                )
              : SizedBox(height: 150),
        ],
      ),
    );
  }
}
