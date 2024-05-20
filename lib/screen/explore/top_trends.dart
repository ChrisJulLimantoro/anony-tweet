import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopTrendsPage extends StatelessWidget {
  const TopTrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Text("This is for the top trends page."),
      ),
    );
  }
}
