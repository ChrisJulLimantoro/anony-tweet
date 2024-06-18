import 'dart:io';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/helpers/hashtags.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPostSheet extends StatefulWidget {
  const AddPostSheet({super.key});

  @override
  State<AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<AddPostSheet> {
  final supabase = Supabase.instance.client;
  final TextEditingController tweetController = TextEditingController();
  List<XFile> images = [];
  bool isLoading = false;
  bool isTextEmpty = true;

  Future<void> pickImage() async {
    try {
      final pickedImages =
          await ImagePicker().pickMultiImage(limit: 4 - images.length);

      setState(() {
        pickedImages.forEach((element) {
          images.add(element);
        });
        debugPrint(images.length.toString());
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) {
        return;
      }

      setState(() {
        // images = pickedImages;
        images.add(pickedImage);
        debugPrint(images.length.toString());
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<bool> postTweet(String creator) async {
    try {
      List<String> fileNames = [];
      List<String> tags = getHashtags(tweetController.text);

      // upload media to supabase
      if (images.isNotEmpty) {
        List<Future<String>> uploadedImages = images.map((image) {
          return uploadImage("tweet_medias", File(image.path),
              "${creator}_${DateTime.now().microsecondsSinceEpoch.toString()}");
        }).toList();

        fileNames = await Future.wait(uploadedImages);
      }

      // insert tweet to supabase
      await supabase.rpc('insert_tweet', params: {
        "creator": context.read<SessionBloc>().id,
        "media": fileNames,
        "tags": tags,
        "tweet": tweetController.text,
      });
      return true;
    } catch (e) {
      debugPrint('Error posting tweet: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    print(context.read<SessionBloc>().displayPhoto);

    return Column(
      children: [
        // Top Buttons
        Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: theme == Brightness.light
                            ? Colors.black
                            : Colors.white),
                  ),
                ),

                // Post button
                ElevatedButton(
                  onPressed: isLoading || tweetController.text.isEmpty
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          bool success = await postTweet(
                              context.read<SessionBloc>().username ?? "");

                          debugPrint("success : $success");

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Tweet posted!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 24,
                                ),
                                behavior: SnackBarBehavior.floating,
                                padding: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            );

                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          } else {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Error posting tweet!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 24,
                                ),
                                behavior: SnackBarBehavior.floating,
                                padding: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(isLoading || isTextEmpty
                            ? Colors.grey
                            : theme == Brightness.light
                                ? Colors.black
                                : Colors.white),
                  ),
                  child: Text(
                    "Post",
                    style: TextStyle(
                        color: theme == Brightness.light
                            ? Colors.white
                            : Colors.black),
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
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: context.read<SessionBloc>().displayPhoto != null
                    ? Image.network(
                        context.read<SessionBloc>().displayPhoto!,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      )
                    : Image.asset(
                        "/lib/assets/images/Logo.png",
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Field
                      TextField(
                        style: TextStyle(
                          color: theme == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        controller: tweetController,
                        autofocus: true,
                        autocorrect: false,
                        maxLength: 280,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorHeight: 16,
                        cursorColor: theme == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.all(0),
                            hintText: "What's on your mind?",
                            counter: null,
                            counterText: "",
                            border: InputBorder.none),
                        onChanged: ((value) {
                          if (value.isEmpty) {
                            setState(() {
                              isTextEmpty = true;
                            });
                          } else {
                            if (isTextEmpty) {
                              setState(() {
                                isTextEmpty = false;
                              });
                            }
                          }
                        }),
                      ),

                      // Image Picker Button
                      Row(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: GestureDetector(
                            onTap: () async {
                              await pickImage();
                            },
                            child: Icon(
                              CupertinoIcons.photo_fill,
                              color: theme == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),

                        // Camera Button
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 24),
                          child: GestureDetector(
                            onTap: () async {
                              await pickImageFromCamera();
                            },
                            child: Icon(
                              CupertinoIcons.camera_fill,
                              color: theme == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ]),

                      // Image Preview
                      images.length > 1 && images.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                    children: images.map(
                                  (image) {
                                    double imageWidth = images.length == 1
                                        ? MediaQuery.of(context).size.width -
                                            MediaQuery.of(context)
                                                .padding
                                                .horizontal -
                                            64
                                        : MediaQuery.of(context).size.width / 3;
                                    double imageHeight = imageWidth * 4 / 3;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Image.file(
                                              File(image.path),
                                              width: imageWidth,
                                              height: imageHeight,
                                              fit: BoxFit.cover,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0, top: 8.0),
                                              child: CircleAvatar(
                                                radius: 13,
                                                backgroundColor: Colors.black,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      images.remove(image);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons.xmark,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ).toList()),
                              ),
                            )
                          : images.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Image.file(
                                          File(images[0].path),
                                          fit: BoxFit.cover,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8.0, top: 8.0),
                                          child: CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Colors.black,
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  images = [];
                                                });
                                              },
                                              icon: const Icon(
                                                CupertinoIcons.xmark,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
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
