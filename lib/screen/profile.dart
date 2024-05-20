import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.arrow_left,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "123456789",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    ));
  }
}
