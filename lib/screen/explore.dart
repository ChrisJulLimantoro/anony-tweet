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
                      Navigator.pushNamed(context, '/top_trends');
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
                if (index == trends.length) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 60.0),
                  );
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
                            initialSearch: trends[index]['title'],
                          ),
                        ),
                      );
                    },
                    // title: Text(
                    //   "Trending in ${trends[index]['trend_location']}",
                    //   style: const TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.black45,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   maxLines: 1,
                    // ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${trends[index]['title']}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<int>(
                          future: getCountTag(tags[index]),
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
              childCount: trends.length + 1,
            ),
          ),
        ],
      ),
      // floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
