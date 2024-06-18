import 'package:anony_tweet/screen/explore.dart';
import 'package:anony_tweet/screen/notifications.dart';
import 'package:anony_tweet/screen/home.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final faker = Faker();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    List<TabItem> items = [
      TabItem(
        icon: index == 0 ? CupertinoIcons.house_fill : CupertinoIcons.house,
      ),
      TabItem(
        icon: index == 1 ? CupertinoIcons.compass_fill : CupertinoIcons.compass,
      ),
      TabItem(
        icon: index == 2 ? CupertinoIcons.bell_fill : CupertinoIcons.bell,
      ),
    ];

    final List<Widget> screens = [
      HomePage(),
      const ExplorePage(),
      const NotificationsPage(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: false,
      body: screens[index],
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: theme == Brightness.light
            ? Colors.white.withAlpha(200)
            : Colors.black.withAlpha(100),
        color: theme == Brightness.light ? Colors.black : Colors.white,
        colorSelected: Colors.white,
        animated: true,
        iconSize: 28,
        padbottom: 8.0,
        indexSelected: index,
        chipStyle: const ChipStyle(convexBridge: true),
        onTap: (idx) {
          setState(() {
            index = idx;
          });
        },
        itemStyle: ItemStyle.circle,
      ),
    );
  }
}
