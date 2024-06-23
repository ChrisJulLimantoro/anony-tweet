import 'package:anony_tweet/widget/add_post_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
    return FloatingActionButton(
      elevation: 1,
      onPressed: () {
        showModalBottomSheet(
          enableDrag: true,
          isDismissible: true,
          elevation: 1,
          useSafeArea: false,
          scrollControlDisabledMaxHeightRatio: 1,
          context: context,
          builder: (BuildContext context) => AddPostSheet(),
        );
      },
      backgroundColor: theme == Brightness.light ? Colors.black : Colors.white,
      child: Icon(
        Icons.add,
        color: theme == Brightness.light ? Colors.white : Colors.black,
      ),
    );
  }
}
