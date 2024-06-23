import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final String? initialSearch;

  SearchPage({
    Key? key,
    required this.initialSearch,
  }) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late PublishSubject<String> _searchSubject;

  late FocusNode _focusNode;
  bool tabChanged = false;
  late TabController _tabController;

  Future<List<Tweet>>? _tweetsFuture;
  List<String> tags = [];
  List<String> recentSearches = [];

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

  Future<String> getDisplayName(String creatorId) async {
    try {
      final response = await supabase
          .from('user')
          .select('display_name')
          .eq('id', creatorId)
          .single();

      return response['display_name'] ?? "";
    } catch (e) {
      print('Error getting display name: $e');
      return "";
    }
  }

  Future<String> getDisplayPhoto(String creatorId) async {
    try {
      final response = await supabase
          .from('user')
          .select('display_photo')
          .eq('id', creatorId)
          .single();

      return response['display_photo'] ?? "lib/assets/logo/Logo.png";
    } catch (e) {
      print('Error getting display photo: $e');
      return "lib/assets/logo/Logo.png";
    }
  }

  Future<Tweet> fromJson(Map<String, dynamic> json) async {
    final userId = context.read<SessionBloc>().id ?? "";

    print("user ID: $userId");

    final likedTweetsResponse =
        await supabase.from('likes').select('tweet_id').eq('user_id', userId);
    final likedTweetIds = <String>{};

    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }

    String username = await getDisplayName(json['creator_id']);
    String profilePicture = await getDisplayPhoto(json['creator_id']);

    final userResponse = await supabase
        .from('user')
        .select('*')
        .eq('id', json['creator_id'])
        .single();
    bool isReTweet = json['retweet_id'] != null;
    String oriCreator = "";
    if (isReTweet) {
      final originalTweetResponse = await supabase
          .from('tweets')
          .select('*')
          .eq('id', json['retweet_id'])
          .single();
      final originalCreatorResponse = await supabase
          .from('user')
          .select('display_name')
          .eq('id', originalTweetResponse['creator_id'])
          .single();
      oriCreator = originalCreatorResponse['display_name'];
    } else {
      final response2 = "";
    }
    final retweetCountResponse = await supabase
        .from('tweets')
        .select()
        .eq('retweet_id', json['id'])
        .eq('creator_id', userId);

    int retweetCount = retweetCountResponse.length;
    print(retweetCount);

    bool isRetweetedByUser = false;
    if (retweetCount > 0) {
      isRetweetedByUser = true;
    }

    return Tweet(
      id: json['id'],
      username: username,
      profilePicture: profilePicture,
      verified: false,
      createdAt: timeAgo(
        DateTime.parse(json['created_at']),
      ),
      content: json['content'],
      media: json['media'] != null ? List<String>.from(json['media']) : [],
      like: json['like'],
      retweet: json['retweet'],
      comment: json['comment'],
      view: 100,
      isLiked: likedTweetIds.contains(json['id']),
      isReTweet: isReTweet,
      oriCreator: oriCreator,
      isRetweetedByUser: isRetweetedByUser,
      isComment: json['comment_id'] != null,
      commentId: json['comment_id'],
    );
  }

  Future<List<Tweet>> searchTweets(
      String search, String tag, String order_by) async {
    var searches = search
        .toLowerCase()
        .split(' ')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final response = await supabase.rpc(
      'gettweet3',
      params: {
        'search': searches,
        'tag': tag,
        'order_by': order_by,
      },
    );

    if (!recentSearches.contains(search)) {
      setState(() {
        recentSearches.add(search);
        saveRecentSearches();
      });
    }

    print(response);

    if (response is List<dynamic>) {
      return Future.wait(
        response.map((item) => fromJson(item)).toList(),
      );
    } else {
      return [];
    }
  }

  Future<void> getTags() async {
    final response = await supabase.rpc('gettags');
    if (response is List<dynamic>) {
      setState(() {
        tags = response.cast<String>().take(9).toList();
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

    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      _tweetsFuture =
          searchTweets(widget.initialSearch!, widget.initialSearch!, "like");
    }

    _searchSubject = PublishSubject<String>();
    _searchSubject.stream
        .debounceTime(Duration(milliseconds: 500))
        .listen((search) {
      if (search.isNotEmpty) {
        setState(() {
          _tweetsFuture = searchTweets(search, search, "like");
        });
      } else {
        setState(() {
          _tweetsFuture = Future.value([]);
        });
      }
    });

    loadRecentSearches();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionBloc = context.read<SessionBloc>();
    final userId = sessionBloc.id;

    if (userId != null && userId.isNotEmpty) {
      final recentSearches =
          prefs.getStringList('recentSearches_$userId') ?? [];
      setState(() {
        this.recentSearches = recentSearches;
      });
    }
  }

  Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionBloc = context.read<SessionBloc>();
    final userId = sessionBloc.id;

    if (userId != null && userId.isNotEmpty) {
      await prefs.setStringList('recentSearches_$userId', recentSearches);
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        tabChanged = _tabController.index == 0;
        String orderBy = _tabController.index == 0 ? "like" : "created_at";
        _tweetsFuture = searchTweets(
            _searchController.text, _searchController.text, orderBy);
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

  Future<void> _refreshTweets() async {
    var order_by = _tabController.index == 0 ? "like" : "created_at";
    setState(() {
      _tweetsFuture = searchTweets(
          _searchController.text, _searchController.text, order_by);
    });
    await _tweetsFuture;
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
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
            hintText: "Search tweets",
            hintStyle: const TextStyle(
              fontSize: 16,
            ),
            focusColor: Colors.blue,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _tweetsFuture = Future.value([]);
                });
              },
              icon: const Icon(
                CupertinoIcons.clear,
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
                saveRecentSearches();
              });
            }
            if (value.isNotEmpty) {
              setState(() {
                _tweetsFuture = searchTweets(value, value, "like");
              });
            } else {
              setState(() {
                _tweetsFuture = Future.value([]);
              });
            }
          },
          onChanged: (value) {
            _searchSubject.add(value);
          },
        ),
        bottom: (_searchController.text.isNotEmpty)
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
            : PreferredSize(
                preferredSize: Size.fromHeight(1.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme == Brightness.light
                            ? Colors.grey.shade200
                            : Colors.grey.shade800,
                        width: 0.5,
                      ),
                    ),
                  ),
                )),
      ),
      body: FutureBuilder<List<Tweet>>(
        future: _tweetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
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
                          GestureDetector(
                            onTap: () {
                              getTags();
                            },
                            child: const Text(
                              "Refresh tags",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: List<Widget>.generate(tags.length, (int index) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = "#" + tags[index];
                          setState(() {
                            _tweetsFuture = searchTweets(_searchController.text,
                                _searchController.text, "like");
                          });
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              recentSearches.clear();
                              saveRecentSearches();
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
                        onTap: () {
                          _searchController.text = recentSearches[index];
                          setState(() {
                            _tweetsFuture = searchTweets(_searchController.text,
                                _searchController.text, "like");
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            final tweets = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshTweets,
                    child: ListView.builder(
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
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshTweets,
                    child: ListView.builder(
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
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
