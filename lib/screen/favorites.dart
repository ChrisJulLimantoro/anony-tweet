import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
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
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.white,
        color: Colors.black,
        colorSelected: Colors.white,
        indexSelected: 2,
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