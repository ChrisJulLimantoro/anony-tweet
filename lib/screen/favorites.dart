import 'package:anony_tweet/widget/CustomBottomNavBar.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

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
    ];
    return Scaffold(
      body: Text("Favorite Page"),
      bottomNavigationBar: CustomBottomNavBar(items: items, index: 2)
    );
  }
}