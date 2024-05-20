import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});

  final List<Map<String, dynamic>> trends = [
    {'trend_location': "Indonesia", 'title': 'menit', 'tweets': '1.2K Tweets'},
    {'trend_location': "Indonesia", 'title': 'menit', 'tweets': '1.2K Tweets'},
    {'trend_location': "Indonesia", 'title': 'menit', 'tweets': '1.2K Tweets'},
    {'trend_location': "Indonesia", 'title': 'menit', 'tweets': '1.2K Tweets'},
    {'trend_location': "Indonesia", 'title': 'menit', 'tweets': '1.2K Tweets'},
    {'trend_location': "Indonesia", 'title': 'menit', 'tweets': '1.2K Tweets'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Anony Tweets",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  focusColor: Colors.blue,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
                // controller: _searchController,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(
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
                  icon: Icon(
                    CupertinoIcons.gear,
                    size: 28,
                  ))
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trends for you",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/top_trends');
                    },
                    child: Text(
                      "Show more",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                            // color: Colors.grey.withOpacity(0.5),
                            // spreadRadius: 1,
                            // blurRadius: 1,
                            // offset: Offset(0, 1),
                            ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        "Trending in " + trends[index]['trend_location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trends[index]['title'],
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            trends[index]['tweets'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.ellipsis_vertical,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: trends.length,
            ),
          ),
        ],
      ),
    );
  }
}
