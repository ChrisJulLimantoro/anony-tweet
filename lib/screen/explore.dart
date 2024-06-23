import 'dart:ui';

import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/screen/search.dart';
import 'package:anony_tweet/widget/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Future<List<String>> getTags() async {
    final response = await supabase.rpc('gettags');
    if (response is List<dynamic>) {
      return response.cast<String>();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Future<List<String>> getRandomizedWords() async {
    final response = await supabase.rpc("getrandomwords");
    if (response is List<dynamic>) {
      return response
          .map((item) {
            String word = item['randomized_word'] as String;
            word = word.replaceAll(RegExp(r'\s+'), '');
            return word;
          })
          .where((word) =>
              word.isNotEmpty && !isEmoji(word) && !word.startsWith('#'))
          .take(10)
          .toList();
    } else {
      throw Exception('Failed to load random words');
    }
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

  Future<int> getCount(String word, String count_mode) async {
    final response = await supabase.rpc('gettweetcount', params: {
      'search': word,
      'count_mode': count_mode,
    });
    return response;
  }

  Future<String?> getDisplayPhoto(BuildContext context) async {
    try {
      final userId = context.read<SessionBloc>().id ?? "";
      final response = await supabase
          .from('user')
          .select('display_photo')
          .eq('id', userId)
          .single();
      return response['display_photo'];
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, List<String>>> fetchTrends() async {
    final tags = await getTags();
    final words = await getRandomizedWords();
    return {
      'tags': tags,
      'words': words,
    };
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
                    hintText: "Search tweets",
                    hintStyle: const TextStyle(
                      fontSize: 16,
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
                        },
                      );
                    },
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.gear,
                    size: 28,
                  ))
            ],
            backgroundColor:
                theme == Brightness.light ? Colors.white : Colors.black,
            shape: Border(
              bottom: BorderSide(
                color: theme == Brightness.light
                    ? Colors.grey.shade200
                    : Colors.grey.shade800,
                width: 0.5,
              ),
            ),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
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
                      setState(() {});
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
          FutureBuilder<Map<String, List<String>>>(
            future: fetchTrends(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, List<String>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                      child: CupertinoActivityIndicator(
                    radius: 14,
                  )),
                );
              } else if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: Center(
                      child: Text('You are not connected to the internet')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No data found')),
                );
              } else {
                final tags = snapshot.data!['tags']!;
                final words = snapshot.data!['words']!;
                return SliverList(
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
                          border: Border(
                            bottom: BorderSide(
                              color: theme == Brightness.light
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade800,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/search',
                              arguments: isTag ? "#$title" : title,
                            );
                          },
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTag ? "#$title" : title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme == Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              FutureBuilder<int>(
                                future: getCount(title, isTag ? "tag" : "word"),
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
                          // trailing: IconButton(
                          //   alignment: Alignment.centerRight,
                          //   onPressed: () {},
                          //   icon: const Icon(
                          //     CupertinoIcons.ellipsis_vertical,
                          //     color: Colors.grey,
                          //     size: 14,
                          //   ),
                          // ),
                        ),
                      );
                    },
                    childCount: tags.length + words.length + 1,
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
