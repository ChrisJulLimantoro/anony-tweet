import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:flutter/widgets.dart';
import 'package:crypt/crypt.dart';

class AddPostSheet extends StatelessWidget {
  const AddPostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;
    final faker = Faker();

    return Column(
      children: [
        // Top Button
        Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: theme == Brightness.light
                            ? Colors.black
                            : Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Post",
                    style: TextStyle(
                        color: theme == Brightness.light
                            ? Colors.white
                            : Colors.black),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        theme == Brightness.light
                            ? Colors.black
                            : Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
        // Add post form
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  faker.image.image(
                    height: 35,
                    width: 35,
                    keywords: ['nature', 'mountain', 'waterfall'],
                    random: true,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextField(
                        autofocus: true,
                        autocorrect: false,
                        maxLength: 280,
                        
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorHeight: 16,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            hintText: "What's on your mind?",
                            border: InputBorder.none),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("PRESSED");
                          },
                          child: Icon(
                            CupertinoIcons.photo_fill,
                            color: theme == Brightness.light
                                ? Colors.black
                                : Colors.white,
                            size: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
