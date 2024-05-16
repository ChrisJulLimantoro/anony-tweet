import 'dart:math';
import 'package:anony_tweet/widget/tweet.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final faker = Faker();

  @override
  Widget build(BuildContext context) {
    const List<TabItem> items = [
      TabItem(
        icon: Icons.home,
        title: 'Home',
      ),
      TabItem(
        icon: Icons.bookmark,
        title: 'Bookmark',
      ),
      TabItem(
        icon: Icons.favorite,
        title: 'Favorites',
      ),
      TabItem(
        icon: Icons.person,
        title: 'Profile',
      ),
      // TabItem(
      //   icon: Icons.shopping_cart_outlined,
      //   title: 'Cart',
      // ),
      // TabItem(
      //   icon: Icons.account_box,
      //   title: 'profile',
      // ),
    ];
    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        title: const Text('PCUFess'),
      ),
      body: ListView(
        children: [
          Tweet(
            username: faker.internet.userName(),
            profilePicture: faker.image.image(
              keywords: ['nature', 'mountain', 'waterfall'],
              random: true,
            ),
            verified: true,
            createdAt: "8h ago",
            content:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
            media: List.generate(
                Random().nextInt(4) + 2,
                (index) => faker.image.image(
                      keywords: ['nature', 'mountain', 'waterfall'],
                      height: 200,
                      width: 200,
                      random: true,
                    )),
            like: 100,
            retweet: 50,
            comment: 20,
            view: 1000,
            isBookmarked: true,
            isLast: false,
            isLiked: true,
          ),
          Tweet(
            username: faker.internet.userName(),
            profilePicture: faker.image.image(
              keywords: ['nature', 'mountain', 'waterfall'],
              random: true,
            ),
            verified: true,
            createdAt: "8h ago",
            content:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.",
            media: List.generate(
                Random().nextInt(4) + 2,
                (index) => faker.image.image(
                      keywords: ['nature', 'mountain', 'waterfall'],
                      height: 200,
                      width: 200,
                      random: true,
                    )),
            like: 100,
            retweet: 50,
            comment: 20,
            view: 1000,
            isBookmarked: false,
            isLast: true,
            isLiked: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("PRESSED");
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.white,
        color: Colors.black,
        colorSelected: Colors.white,
        indexSelected: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/bookmark');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/favorite');
          }else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        chipStyle: const ChipStyle(convexBridge: true),
        itemStyle: ItemStyle.circle,
        
        animated: false,
      ),
    );
  }
}
