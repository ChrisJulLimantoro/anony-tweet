import 'package:anony_tweet/SessionProvider.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/screen/search_page.dart';
import 'package:anony_tweet/widget/drawer.dart';
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
            .map((item) {
              String word = item['randomized_word'] as String;
              word = word.replaceAll(RegExp(r'\s+'), '');
              // word = word.replaceAll(
              //     RegExp(r'\W'), '');
              return word;
            })
            .where((word) =>
                word.isNotEmpty && !isEmoji(word) && !word.startsWith('#'))
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

  Future<int> getCountWord(String word) async {
    final response = await supabase.rpc('get_tweet_count_by_word', params: {
      'word_to_search': word,
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

  Future<String?> getDisplayPhoto(BuildContext context) async {
    try {
      final userId = SessionContext.of(context)!.id;

      final response = await supabase
          .from('user')
          .select('display_photo')
          .eq('id', userId)
          .single();
      return response['display_photo'];
    } catch (e) {
      print('Error fetching display photo: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
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
            leading: Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FutureBuilder<String?>(
                    future: getDisplayPhoto(context),
                    builder: (context, snapshot) {
                      Widget displayImage;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        displayImage = Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 32,
                          color: (theme == Brightness.light
                              ? Colors.black
                              : Colors.white),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        displayImage = Image.network(
                          snapshot.data!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            CupertinoIcons.person_crop_circle_fill,
                            size: 32,
                            color: (theme == Brightness.light
                                ? Colors.black
                                : Colors.white),
                          ),
                        );
                      } else {
                        displayImage = Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          size: 32,
                          color: (theme == Brightness.light
                              ? Colors.black
                              : Colors.white),
                        );
                      }

                      return IconButton(
                        icon: ClipOval(child: displayImage),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                          debugPrint("PRESSED");
                        },
                      );
                    },
                  ),
                );
              },
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                bool isTag;
                if (index < tags.length) {
                  title = tags[index];
                  isTag = true;
                } else {
                  title = words[index - tags.length];
                  isTag = false;
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
                            initialSearch: isTag ? "#$title" : title,
                          ),
                        ),
                      );
                    },
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTag ? "#$title" : title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isTag)
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
                                return Text("${snapshot.data} posts");
                              }
                            },
                          )
                        else
                          FutureBuilder<int>(
                            future: getCountWord(title),
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading...");
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else {
                                return Text("${snapshot.data} posts");
                              }
                            },
                          )
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
      drawer: MyDrawer(),
      // floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
