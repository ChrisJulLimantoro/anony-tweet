import 'package:anony_tweet/widget/custom_fab.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopTrendsPage extends StatelessWidget {
  TopTrendsPage({
    super.key,
  });

  final Faker faker = new Faker();

  List<Map<String, dynamic>> generateTrends() {
    List<Map<String, dynamic>> trends = [];
    for (int i = 0; i < 20; i++) {
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
      appBar: AppBar(
        title: Text(
          "Top Trends",
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.gear,
                size: 28,
              ))
        ],
      ),
      body: ListView.builder(
        itemCount: trends.length,
        itemBuilder: (context, index) {
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
      ),
      floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
