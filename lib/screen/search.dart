import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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

class SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late PublishSubject<String> _searchSubject;

  late FocusNode _focusNode;
  bool isSearching = false;
  bool tabChanged = false;
  late TabController _tabController;

  List<Tweet> tweets = [];
  List<String> tags = [];
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
        isReTweet: false,
        oriCreator: "Dummy");
  }

  Future searchTweets(String search, String tag, String order_by) async {
    final response = await supabase.rpc(
      'gettweet',
      params: {
        'search': search,
        'tag': tag,
        'order_by': order_by,
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

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    getTags();
    _focusNode = FocusNode();
    _searchController = TextEditingController();

    // print("INITIAL SEARCH " + widget.initialSearch.toString()!);

    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      searchTweets(widget.initialSearch!, widget.initialSearch!, "created_at");
    }

    _searchSubject = PublishSubject<String>();
    _searchSubject.stream
        .debounceTime(Duration(milliseconds: 600))
        .listen((search) {
      if (search.isNotEmpty) {
        searchTweets(search, search, "created_at");
      } else {
        setState(() {
          tweets = [];
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        tabChanged = _tabController.index == 0;
        String orderBy = _tabController.index == 0 ? "created_at" : "like";
        searchTweets(_searchController.text, _searchController.text, orderBy);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _searchSubject.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  tweets = [];
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
              searchTweets(value, value, "created_at");
              // setState(() {
              // });
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
        bottom: (tweets.isNotEmpty)
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: "Top",
                  ),
                  Tab(
                    text: "Latest",
                  ),
                ],
              )
            : null,
      ),
      body: (!tweets.isNotEmpty)
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 16.0,
                    right: 16.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 16,
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
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: List<Widget>.generate(tags.length, (int index) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = "#" + tags[index];
                        searchTweets(tags[index], tags[index], "created_at");
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
                    top: 8.0,
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
                            fontSize: 16,
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
            )
          : Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: tweets.length,
                    itemBuilder: (context, index) {
                      return SingleTweet(
                        tweet: tweets[index],
                        isBookmarked: true,
                        isLast: false,
                        isLiked: tweets[index].isLiked,
                        searchTerm: _searchController.text,
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: tweets.length,
                    itemBuilder: (context, index) {
                      return SingleTweet(
                        tweet: tweets[index],
                        isBookmarked: true,
                        isLast: false,
                        isLiked: tweets[index].isLiked,
                        searchTerm: _searchController.text,
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}
