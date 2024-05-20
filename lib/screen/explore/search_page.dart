import 'package:anony_tweet/widget/circular_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;
  bool _requestFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_focusNode));
      _requestFocus = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _focusNode,
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
      body: Column(
        children: [
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
                  Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //     CupertinoIcons.xmark_circle_fill,
                  //   ),
                  // )
                  Text(
                    "Clear",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 125,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProfile(
                    profileImage: faker.image.image(
                      keywords: ['nature', 'mountain', 'waterfall'],
                      random: true,
                    ),
                    username: Faker().internet.userName(),
                    displayName: Faker().person.name(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(Faker().person.name()),
                  // subtitle: Text(Faker().internet.email()),
                  trailing: Transform.rotate(
                    angle: -135.0 * (3.14159265359 / 180.0),
                    child: Icon(
                      CupertinoIcons.arrow_right,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
