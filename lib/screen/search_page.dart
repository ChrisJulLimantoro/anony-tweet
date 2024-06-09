import 'dart:math';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class SearchPage extends StatefulWidget {
  final String? initialSearch;
  // final Map<String, dynamic> tweetArguments;

  SearchPage({
    Key? key,
    required this.initialSearch,
    // required this.tweetArguments,
  }) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;
  bool _requestFocus = false;
  late TextEditingController _searchController;
  late PublishSubject<String> _searchSubject;

  List<String> tags = [];

  List<Tweet> tweets = [];

  List<String> recentSearches = [];

  Future<void> getTags() async {
    final response = await supabase.rpc('gettags');
    if (response is List<dynamic>) {
      setState(() {
        tags = response.cast<String>();
      });
    }
  }

  Future<Tweet> fromJson(Map<String, dynamic> json) async {
    String timeAgo(DateTime timestamp) {
      DateTime now = DateTime.now();
      Duration difference = now.difference(timestamp);

      if (difference.inDays >= 365) {
        int years = (difference.inDays / 365).floor();
        return "${years}y ago";
      } else if (difference.inDays >= 30) {
        int months = (difference.inDays / 30).floor();
        return "${months}m ago";
      } else if (difference.inDays >= 7) {
        int weeks = (difference.inDays / 7).floor();
        return "${weeks}w ago";
      } else if (difference.inDays >= 1) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours >= 1) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes >= 1) {
        return "${difference.inMinutes}m ago";
      } else {
        return "${difference.inSeconds}s ago";
      }
    }

    Future<String> getDisplayName() async {
      try {
        if (json['creator_id'] == null) {
          return "";
        }

        final response = await supabase
            .from('user')
            .select('display_name')
            .eq('id', json['creator_id'])
            .single();

        return response['display_name'] ?? "";
      } catch (e) {
        print('Error getting display name: $e');
        return "";
      }
    }

    Future<String> getDisplayPhoto() async {
      try {
        if (json['creator_id'] == null) {
          return "";
        }

        final response = await supabase
            .from('user')
            .select('display_photo')
            .eq('id', json['creator_id'])
            .single();

        return response['display_photo'] ?? "";
      } catch (e) {
        print('Error getting display photo: $e');
        return "";
      }
    }

    String username = await getDisplayName();
    String profilePicture = await getDisplayPhoto();

    return Tweet(
        id: '1',
        username: username,
        profilePicture: profilePicture,
        verified: false,
        createdAt: timeAgo(DateTime.parse(json['created_at'])),
        content: json['content'],
        media: json['media'] != null ? List<String>.from(json['media']) : [],
        like: json['like'],
        retweet: json['retweet'],
        comment: json['comment'],
        view: 0,
        isLiked: false,
        isReTweet: false);
  }

  Future searchTweets(String search, String tag) async {
    final response = await supabase.rpc(
      'gettweet',
      params: {
        'search': search,
        'tag': tag,
      },
    );

    if (!recentSearches.contains(search)) {
      setState(() {
        recentSearches.add(search);
      });
    }

    print(response);

    if (response is List<dynamic>) {
      tweets =
          await Future.wait(response.map((item) => fromJson(item)).toList());
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();
    getTags();
    _searchSubject = PublishSubject<String>();
    _searchSubject.stream
        .debounceTime(Duration(milliseconds: 600))
        .listen((search) {
      if (search.isNotEmpty) {
        searchTweets(search, search);
      } else {
        setState(() {
          tweets = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode),
      );
      _requestFocus = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: "Search Anony Tweets",
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            focusColor: Colors.blue,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 1,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade700,
          ),
          controller: _searchController,
          onSubmitted: (value) {
            if (!recentSearches.contains(value)) {
              setState(() {
                recentSearches.add(value);
              });
            }
            if (value.isNotEmpty) {
              searchTweets(value, value);
            } else {
              setState(() {
                tweets = [];
              });
            }
          },
          onChanged: (value) {
            _searchSubject.add(value);
          },
        ),
      ),
      body: Column(
        children: [
          if (tweets.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Refresh tags",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List<Widget>.generate(tags.length, (int index) {
                return GestureDetector(
                  onTap: () {
                    searchTweets(tags[index], tags[index]);
                  },
                  child: Chip(
                    label: Text("#${tags[index]}"),
                    onDeleted: () {
                      setState(() {
                        tags.removeAt(index);
                      });
                    },
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent searches',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          recentSearches.clear();
                        });
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(recentSearches[index]),
                    trailing: Transform.rotate(
                      angle: -135.0 * (3.14159265359 / 180.0),
                      child: const Icon(
                        CupertinoIcons.arrow_right,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (tweets.isNotEmpty) ...[
            SingleChildScrollView(
              child: Column(
                children: tweets.map((tweet) {
                  return SingleTweet(
                    tweet: tweet,
                    isBookmarked: Random().nextDouble() <= 0.5 ? true : false,
                    isLast: tweets.last == tweet,
                    isLiked: Random().nextDouble() <= 0.5 ? true : false,
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
