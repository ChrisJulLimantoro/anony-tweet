import 'dart:math';
import 'package:intl/intl.dart';
import 'package:anony_tweet/main.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/hashtag.dart';
import 'package:anony_tweet/widget/single_tweet.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:anony_tweet/SessionProvider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  Future<String> getName(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('display_name')
        .eq('id', SessionContext.of(context)!.id)
        .single();
    return response['display_name'];
  }

  Future<String> getPhoto(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('display_photo')
        .eq('id', SessionContext.of(context)!.id)
        .single();
    return response['display_photo'];
  }

  Future<String> getDate(BuildContext context) async {
    final response = await supabase
        .from('user')
        .select('created_at')
        .eq('id', SessionContext.of(context)!.id)
        .single();
    return response['created_at'];
  }

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
                                child: FutureBuilder<String>(
                                  future: getPhoto(context),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Icon(Icons.error);
                                    } else if (snapshot.hasData) {
                                      return ClipOval(
                                        child: Image.network(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: screenWidth * 0.256,
                                          height: screenWidth * 0.256,
                                        ),
                                      );
                                    } else {
                                      return Image.asset(
                                          "lib/assets/logo/Logo.png");
                                    }
                                  },
                                ),
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
                  FutureBuilder<String>(
                    future: getName(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: Container(
                                    width: screenWidth * 0.7,
                                    child: Text(
                                      snapshot.data!,
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
                                        FutureBuilder<String>(
                                          future: getDate(context),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Image.asset(
                                                  "assets/logo/Logo.png");
                                            } else {
                                              return Text(
                                                '${DateFormat('dd MMM yyyy').format(DateTime.parse(snapshot.data!))}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            }
                                          },
                                        )
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
                        );
                      } else {
                        return Text('No data');
                      }
                    },
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
