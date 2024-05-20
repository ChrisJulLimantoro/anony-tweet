import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircularProfile extends StatelessWidget {
  final String profileImage;
  final String username;
  final String displayName;

  const CircularProfile({
    Key? key,
    required this.profileImage,
    required this.username,
    required this.displayName,
  }) : super(key: key);

  String limitCharacters(String text, int limit) {
    if (text.length <= limit) {
      return text;
    } else {
      return text.substring(0, limit) + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(profileImage),
          radius: 30.0,
        ),
        SizedBox(height: 10.0),
        Text(
          limitCharacters(displayName, 10),
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '@' + limitCharacters(username, 10),
          style: TextStyle(
            fontSize: 11.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
