import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/blocs/bookmark_bloc.dart';
import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore_for_file: prefer_const_constructors

class SingleTweet extends StatelessWidget {
  final Tweet tweet;
  final bool isBookmarked;
  final bool isLiked;
  final bool isLast;

  const SingleTweet({
    super.key,
    required this.tweet,
    required this.isBookmarked,
    required this.isLast,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final userId = SessionContext.of(context)!.id; 
    // debugPrint(tweet.verified.toString());
    return MultiBlocProvider(
      providers: [
        BlocProvider<LikeButtonBloc>(
          create: (context) => LikeButtonBloc(
              likeCount: tweet.like,
              isLiked: tweet.isLiked,
              userId: userId,
              tweetId: tweet.id),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(isBookmarked),
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
                    tweet.profilePicture,
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
                                color: Colors.grey.shade500, fontSize: 12.0),
                          )
                        ],
                      ),
                      HashtagText(
                        text: tweet.content,
                        onTagTap: (String tag) {
                          print("Tapped on $tag");
                          // You can add more actions here, like navigating to another page or showing a modal.
                        },
                      ),
                      // Text(
                      //   tweet.content,
                      //   style: TextStyle(
                      //     fontSize: 16.0,
                      //   ),
                      // ),
                      SizedBox(
                        height: 8,
                      ),
                      if (tweet.media.isNotEmpty)
                        SizedBox(
                          height: 200,
                          width: tweet.media.length * 200.0 >
                                  MediaQuery.of(context).size.width
                              ? MediaQuery.of(context).size.width
                              : tweet.media.length * 200.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ListView(
                              clipBehavior: Clip.none,
                              physics: PageScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: tweet.media.map((e) {
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
                      ActionRow(tweet: tweet)
                    ],
                  ),
                ),
              ],
            ),
          ),
          !isLast
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(
                    height: 0.1,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade800,
                  ),
                )
              : SizedBox(height: 150),
        ],
      ),
    );
  }
}
