import 'dart:math';
import 'package:anony_tweet/model/tweet.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/widget/single_tweet_comment.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:anony_tweet/helpers/hashtags.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PostComment extends StatefulWidget {
  const PostComment({super.key, required this.id});
  final String id;

  @override
  State<PostComment> createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  final supabase = Supabase.instance.client;
  final TextEditingController tweetController = TextEditingController();
  List<XFile> images = [];
  bool isLoading = false;
  bool isTextEmpty = true;

  String customTimeStamp(DateTime timestamp) {
    DateTime localDateTime = timestamp.toLocal();
    DateFormat formatter = DateFormat("hh:mm a · MMMM dd, yyyy");
    String formatted = formatter.format(localDateTime);
    return formatted;
  }

  Future<void> pickImage() async {
    try {
      final pickedImages =
          await ImagePicker().pickMultiImage(limit: 4 - images.length);

      setState(() {
        pickedImages.forEach((element) {
          images.add(element);
        });
      });
    } on PlatformException catch (e) {}
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
      });
    } on PlatformException catch (e) {}
  }

  Future<bool> postComment(String creator) async {
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
      await supabase.rpc('comment', params: {
        "creator": context.read<SessionBloc>().id,
        "comment_media": fileNames,
        "comment_tags": tags,
        "comment_content": tweetController.text,
        "old_id": widget.id
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Tweet> fetchTweet(String id, BuildContext context) async {
    final userId = context.read<SessionBloc>().id ?? "";
    final likedTweetsResponse = await Supabase.instance.client
        .from('likes')
        .select('tweet_id')
        .eq('user_id', userId);
    final likedTweetIds = <String>{};
    for (var record in likedTweetsResponse) {
      likedTweetIds.add(record['tweet_id']);
    }
    // }
    final response = await Supabase.instance.client
        .from('tweets')
        .select('*')
        .eq('id', id)
        .single();

    final userResponse = await Supabase.instance.client
        .from('user')
        .select('*')
        .eq('id', response['creator_id'])
        .single();
    DateTime createdAt = DateTime.parse(response['created_at']);
    final retweetCountResponse = await Supabase.instance.client
        .from('tweets')
        .select()
        .eq('retweet_id', response['id'])
        .eq('creator_id', userId);

    int retweetCount = retweetCountResponse.length;

    bool isRetweetedByUser = false;
    if (retweetCount > 0) {
      isRetweetedByUser = true;
    }
    bool isReTweet = response['retweet_id'] != null;
    String oriCreator = "";
    if (isReTweet) {
      final originalTweetResponse = await Supabase.instance.client
          .from('tweets')
          .select('*')
          .eq('id', response['retweet_id'])
          .single();
      final originalCreatorResponse = await Supabase.instance.client
          .from('user')
          .select('display_name')
          .eq('id', originalTweetResponse['creator_id'])
          .single();
      oriCreator = originalCreatorResponse['display_name'];
    } else {
      // final response2 = "";
    }
    return Tweet(
      id: response['id'],
      username: userResponse['display_name'],
      profilePicture: userResponse['display_photo'],
      verified: false,
      createdAt: customTimeStamp(createdAt),
      content: response['content'],
      media: response['media'] != null
          ? List<String>.from(response['media'].map((item) => item as String))
          : [],
      like: response['like'],
      retweet: response['retweet'],
      comment: response['comment'],
      view: 100,
      isLiked: likedTweetIds.contains(response['id']),
      isReTweet: isReTweet,
      oriCreator: oriCreator,
      isRetweetedByUser: isRetweetedByUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      backgroundColor: theme == Brightness.light ? Colors.white : Colors.black,
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 5),
        //   child: Center(child: Text("Cancel", style: TextStyle(fontSize: 16),)),
        // ),
        shape: Border(
          bottom: BorderSide(
            color: theme == Brightness.light
                ? Colors.grey.shade200
                : Colors.grey.shade800,
            width: 0.5,
          ),
        ),
        title: TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: theme == Brightness.light ? Colors.black : Colors.white,
              fontSize: 18,
            ),
          ),
          onPressed: () {
            Navigator.popAndPushNamed(context, "/comment");
          },
        ),
        centerTitle: false,
        backgroundColor:
            theme == Brightness.light ? Colors.white : Colors.black,
        elevation: 1,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: isLoading || tweetController.text.isEmpty
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      bool success = await postComment(
                          context.read<SessionBloc>().username ?? "");

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Comment posted!",
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
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                FutureBuilder<Tweet>(
                    future: fetchTweet(widget.id, context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center();
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleTweetComment(
                                tweet: snapshot.data!,
                                isBookmarked: Random().nextDouble() <= 0.5,
                                isLast: false,
                                isLiked: snapshot.data!.isLiked,
                                searchTerm: "",
                              )
                            ],
                          ),
                        );
                      } else {
                        return Center(child: Text("No tweet found."));
                      }
                    }),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        "https://randomuser.me/api/portraits/men/34.jpg",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
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
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 24),
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
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                MediaQuery.of(context)
                                                    .padding
                                                    .horizontal -
                                                64
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3;
                                        double imageHeight = imageWidth * 4 / 3;

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0, top: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor:
                                                        Colors.black,
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
                  ],
                )
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
