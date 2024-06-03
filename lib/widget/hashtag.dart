import 'package:flutter/gestures.dart'; 
import 'package:flutter/material.dart';

class HashtagText extends StatelessWidget {
  final String text;
  final Function(String) onTagTap;

  HashtagText({required this.text, required this.onTagTap});

  @override
  Widget build(BuildContext context) {
    // Split text into words
    List<String> words = text.split(' ');

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: words.map((word) {
          // Check if the word starts with a hashtag
          if (word.startsWith('#')) {
            return TextSpan(
              text: '$word ',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Trigger action when hashtag is tapped
                  onTagTap(word);
                },
            );
          } else {
            return TextSpan(
              text: '$word ',
            );
          }
        }).toList(),
      ),
    );
  }
}
