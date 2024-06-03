import 'dart:math';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.search),
                onPressed: () {},
              ),
            ],
            pinned: true,
            floating: true,
            backgroundColor: Colors.grey.shade300,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: screenHeight * 0.10,
                        color: Colors.grey.shade300,
                      ),
                      Positioned(
                        top: screenHeight * 0.035,
                        left: screenWidth * 0.06,
                        child: Container(
                          width: screenWidth * 0.28,
                          height: screenWidth * 0.28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: screenWidth * 0.128,
                                backgroundImage:
                                    AssetImage("lib/assets/logo/Logo.png"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.11,
                        right: screenWidth * 0.03,
                        child: TextButton(
                          child: Text(
                            "Edit profile",
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            debugPrint("PRESSED");
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.07),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.085),
                  Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06),
                            child: Container(
                              width: screenWidth * 0.7,
                              child: Text(
                                "ASIMELEKITI129",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06),
                            child: Container(
                              width: screenWidth * 0.7,
                              child: Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06),
                            child: Container(
                              width: screenWidth * 0.7,
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    color: Colors.grey,
                                    size: screenHeight * 0.02,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "Joined May 2024",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06),
                            child: Container(
                              width: screenWidth * 0.7,
                              child: Row(
                                children: [
                                  Text(
                                    "290",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    " Posts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "120",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    " Replies",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          _buildNavItem(0, 'Posts'),
                          _buildNavItem(1, 'Replies'),
                          _buildNavItem(2, 'Liked')
                        ],
                      ),
                      Container(
                        // height: screenHeight * 0.5,
                        child: _selectedIndex == 0
                            ? PostsPage()
                            : _selectedIndex == 1
                                ? RepliesPage()
                                : LikedPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedIndex == index ? Colors.blue : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight:
                _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedIndex == index ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }
}

class PostsPage extends StatelessWidget {
  @override
  List<Tweet> tweets = List.generate(10, (index) {
    return Tweet(
      username: faker.internet.userName(),
      profilePicture:
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
      // profilePicture: faker.image.image(
      //   keywords: ['nature', 'mountain', 'waterfall'],
      //   random: true,
      // ),
      // profilePicture: "",
      verified: Random().nextDouble() <= 0.5 ? true : false,
      createdAt: "${Random().nextInt(23)}h ago",
      content: "saya punya babi #anjing #leo",
      media: [],
      // media: List.generate(
      //     Random().nextInt(4),
      //     (index) => faker.image.image(
      //           keywords: ['nature', 'mountain', 'waterfall'],
      //           height: 200,
      //           width: 200,
      //           random: true,
      //         )),
      like: Random().nextInt(1000),
      retweet: Random().nextInt(1000),
      comment: Random().nextInt(1000),
      view: Random().nextInt(900) + 100,
    );
  });
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: tweets
            .mapIndexed(
              (index, tweet) => SingleTweet(
                tweet: tweet,
                isBookmarked: Random().nextDouble() <= 0.5 ? true : false,
                isLast: index == tweets.length - 1 ? true : false,
                isLiked: Random().nextDouble() <= 0.5 ? true : false,
              ),
            )
            .toList(),
      ),
    );
  }
}

class RepliesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Liked Content',
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

class LikedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Liked Content',
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}
