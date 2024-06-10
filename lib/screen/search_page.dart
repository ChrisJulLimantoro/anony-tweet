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
  late TextEditingController _searchController;
  late PublishSubject<String> _searchSubject;

  late FocusNode _focusNode;
  bool _requestFocus = false;

  List<String> tags = [];

  List<Tweet> tweets_sorted_created = [];
  List<Tweet> tweets_sorted_top = [];

  List<String> recentSearches = [];

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

        return response['display_photo'] ?? "lib/assets/logo/Logo.png";
      } catch (e) {
        print('Error getting display photo: $e');
        return "lib/assets/logo/Logo.png";
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
      tweets_sorted_created =
          await Future.wait(response.map((item) => fromJson(item)).toList());
      setState(() {});

      // tweets_sorted_created.sort((a, b) {
      //   var dateA = DateTime.parse(a.createdAt);
      //   var dateB = DateTime.parse(b.createdAt);
      //   return dateA.compareTo(dateB);
      // });
    }
  }

  Future<void> getTags() async {
    final response = await supabase.rpc('gettags');
    if (response is List<dynamic>) {
      setState(() {
        tags = response.cast<String>();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTags();
    _focusNode = FocusNode();
    _searchController = TextEditingController();

    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      searchTweets(widget.initialSearch!, widget.initialSearch!);
    }

    _searchSubject = PublishSubject<String>();
    _searchSubject.stream
        .debounceTime(Duration(milliseconds: 600))
        .listen((search) {
      if (search.isNotEmpty) {
        searchTweets(search, search);
      } else {
        setState(() {
          tweets_sorted_created = [];
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                CupertinoIcons.arrow_left,
              ),
            ),
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
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      tweets_sorted_created = [];
                    });
                  },
                  icon: const Icon(
                    CupertinoIcons.clear,
                    color: Colors.black54,
                  ),
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
                    tweets_sorted_created = [];
                  });
                }
              },
              onChanged: (value) {
                _searchSubject.add(value);
              },
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Top",
                ),
                Tab(
                  text: "Latest",
                ),
              ],
            )),
        body: TabBarView(
          children: [
            Column(
              children: [
                if (tweets_sorted_created.isEmpty) ...[
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
                if (tweets_sorted_created.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: tweets_sorted_created.map((tweet) {
                          return SingleTweet(
                            tweet: tweet,
                            isBookmarked:
                                Random().nextDouble() <= 0.5 ? true : false,
                            isLast: tweets_sorted_created.last == tweet,
                            isLiked:
                                Random().nextDouble() <= 0.5 ? true : false,
                            searchTerm: _searchController.text,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Column(
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
