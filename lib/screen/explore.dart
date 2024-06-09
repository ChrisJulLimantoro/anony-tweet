import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/screen/search_page.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<String> tags = [];
  List<String> words = [];

  List<Map<String, dynamic>> generateTrends() {
    List<Map<String, dynamic>> trends = [];
    for (int i = 0; i < tags.length; i++) {
      trends.add({
        // 'trend_location': faker.address.country(),
        'title': tags[i],
      });
    }
    return trends;
  }

  Future<void> getTags() async {
    final response = await supabase.rpc('gettags');
    if (response is List<dynamic>) {
      setState(() {
        tags = response.cast<String>();
      });
    }
  }

  Future<void> getRandomizedWords() async {
    final response = await supabase.rpc("get_randomized_words_from_content");
    if (response is List<dynamic>) {
      setState(() {
        words = response
            .map((item) => item['randomized_word'] as String)
            .where((word) => word.isNotEmpty && !isEmoji(word) && !word.startsWith('#'))
            .take(5)
            .toList();
      });
    }
    print(words);
  }

  bool isEmoji(String s) {
    int codePoint = s.runes.first;
    return (codePoint >= 0x1F600 && codePoint <= 0x1F64F) ||
        (codePoint >= 0x1F300 && codePoint <= 0x1F5FF) ||
        (codePoint >= 0x1F680 && codePoint <= 0x1F6FF) ||
        (codePoint >= 0x2600 && codePoint <= 0x26FF) ||
        (codePoint >= 0x2700 && codePoint <= 0x27BF) ||
        (codePoint >= 0xFE00 && codePoint <= 0xFE0F) ||
        (codePoint >= 0x1F900 && codePoint <= 0x1F9FF) ||
        (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF);
  }

  Future<int> getCountTag(String tag) async {
    final response = await supabase.rpc('gettagcount', params: {
      'tag': tag,
    });
    // print("TOTAL COUNT" + response.toString());
    return response;
  }

  @override
  void initState() {
    super.initState();
    getTags();
    getRandomizedWords();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> trends = generateTrends();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                child: TextField(
                  enabled: false,
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                  // controller: _searchController,
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  size: 32,
                ),
                onPressed: () {
                  print("PRESSED");
                },
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    print("PRESSED");
                  },
                  icon: const Icon(
                    CupertinoIcons.gear,
                    size: 28,
                  ))
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Trends for you",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      getRandomizedWords();
                    },
                    child: const Text(
                      "Refresh trends",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == tags.length + words.length) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                  );
                }
                String title;
                bool isTrend;
                if (index < tags.length) {
                  title = tags[index];
                  isTrend = true;
                } else {
                  title = words[index - tags.length];
                  isTrend = false;
                }
                return Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.3,
                      ),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(
                            initialSearch: title,
                          ),
                        ),
                      );
                    },
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTrend ? "#$title" : title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isTrend)
                          FutureBuilder<int>(
                            future: getCountTag(title),
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading...");
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else {
                                return Text("${snapshot.data} Tweets");
                              }
                            },
                          )
                        else
                          Text("xxx tweets")
                      ],
                    ),
                    trailing: IconButton(
                      alignment: Alignment.centerRight,
                      onPressed: () {},
                      icon: const Icon(
                        CupertinoIcons.ellipsis_vertical,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ),
                  ),
                );
              },
              childCount: tags.length + words.length + 1,
            ),
          ),
        ],
      ),
      // floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
