import 'package:anony_tweet/model/tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore_for_file: prefer_const_constructors

class Comment extends StatelessWidget {
  final Tweet tweet;
  final bool isLast;

  const Comment({
    super.key,
    required this.tweet,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    debugPrint(tweet.verified.toString());
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
                      tweet.content,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
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
    );
  }
}
