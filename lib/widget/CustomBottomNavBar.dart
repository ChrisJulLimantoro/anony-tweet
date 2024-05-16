import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, required this.items, required this.index});
  final List<TabItem> items;
  final int index;
  @override
  Widget build(BuildContext context) {
    return BottomBarInspiredInside(
        items: items,
        backgroundColor:  Colors.white,
        color: Colors.black,
        colorSelected: Colors.white,
        indexSelected: index,
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
        
        animated: true,
      );
  }
}