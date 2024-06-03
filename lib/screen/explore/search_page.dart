import 'dart:math';

import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;
  bool _requestFocus = false;
  final TextEditingController _searchController = TextEditingController();

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

    if (response is List<dynamic>) {
      setState(() {
        tweets = response.map((item) => Tweet.fromJson(item)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    getTags();
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        searchTweets(_searchController.text, _searchController.text);
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
