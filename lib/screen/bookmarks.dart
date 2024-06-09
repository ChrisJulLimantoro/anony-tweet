import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(CupertinoIcons.ellipsis_vertical),
            onSelected: (String result) {
              if (result == 'Clear all bookmarks') {
                // Handle clearing all bookmarks here
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear_bookmarks',
                child: Text('Clear all bookmarks'),
              ),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Text('Save your favorite tweets here!'),
      ),
    );
  }
}
