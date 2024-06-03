import 'package:anony_tweet/widget/custom_fab.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});

  final faker = new Faker();

  List<Map<String, dynamic>> generateTrends() {
    List<Map<String, dynamic>> trends = [];
    for (int i = 0; i < 15; i++) {
      trends.add({
        'trend_location': faker.address.country(),
        'title': faker.lorem.word(),
        'tweets': '${faker.randomGenerator.integer(9999)}K Tweets',
      });
    }
    return trends;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> trends = generateTrends();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                child: TextField(
                  enabled: false,
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
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 8.0,
              ),
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
                if (index == trends.length) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 60.0),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.3,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      "Trending in " + trends[index]['trend_location'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trends[index]['title'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
                      alignment: Alignment.topRight,
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.ellipsis_vertical,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ),
                  ),
                );
              },
              childCount: trends.length + 1, // Increase the child count by 1
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
