import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:anony_tweet/blocs/session_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    Future<void> uploadImage(File imageFile) async {
      // final storageResponse = await supabase.storage.createBucket('avatars');

      try {
        await supabase.storage
            .from("tweet_medias") // Replace with your storage bucket name
            .upload(
                "${context.read<SessionBloc>().username}_${DateTime.now().microsecondsSinceEpoch.toString()}",
                imageFile);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    Future<bool> postTweet() async {
      try {
        images.forEach((image) {
          uploadImage(File(image.path));
        });
        return true;
      } catch (e) {
        debugPrint('Error uploading image: $e');
        return false;
      }

      // await supabase.rpc('insert_tweets', params: {
      //   "creator": context.read<SessionBloc>().id,
      //   "media": images.isNotEmpty ? images.map((e) => e.path).toList() : [],
      //   "tags": "",
      //   "tweet": tweetController.text,
      // });
    }

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
                  onPressed: () async {
                    await postTweet();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        theme == Brightness.light
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
