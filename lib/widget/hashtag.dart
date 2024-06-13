import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HashtagText extends StatelessWidget {
  final String text;
  final String searchTerm;
  final Function(String) onTagTap;

  HashtagText({
    required this.text,
    required this.searchTerm,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    // Split text into words
    List<String> words = text.split(' ');
    List<String> searchWords = searchTerm.toLowerCase().split(' ');

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: words.map((word) {
          if (searchWords.any(
                (searchWord) {
                  return word.toLowerCase() == searchWord;
                },
              ) &&
              word.startsWith("#")) {
            return TextSpan(
              text: '$word ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Trigger action when hashtag is tapped
                  onTagTap(word);
                },
            );
          }
          // Check if the word starts with a hashtag
          else if (word.startsWith('#')) {
            return TextSpan(
              text: '$word ',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Trigger action when hashtag is tapped
                  onTagTap(word);
                },
            );
          }
          // Check if the word is the search term
          else if (searchWords.any(
            (searchWord) {
              return word.toLowerCase() == searchWord;
            },
          )) {
            return TextSpan(
              text: '$word ',
              style: TextStyle(fontWeight: FontWeight.bold),
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
