import 'package:anony_tweet/blocs/session_bloc.dart';
import 'package:anony_tweet/helpers/storage.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/widget/action_row.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoCarouselScreen extends StatefulWidget {
  final Tweet tweet;
  final String selected;

  const PhotoCarouselScreen(
      {super.key, required this.tweet, required this.selected});

  @override
  State<PhotoCarouselScreen> createState() => _PhotoCarouselScreenState();
}

class _PhotoCarouselScreenState extends State<PhotoCarouselScreen> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    this._current = widget.tweet.media.indexOf(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(64, 0, 0, 0),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.arrow_down_to_line,
              color: Colors.white,
            ),
            onPressed: () {
              downloadImage(
                  getImageUrl("tweet_medias", widget.tweet.media[_current]));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(),
            CarouselSlider(
              items: widget.tweet.media.map((image) {
                return Hero(
                  tag:
                      "${widget.tweet.id}_${image.toString()}",
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl("tweet_medias", image.toString()),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                initialPage: widget.tweet.media.indexOf(widget.selected),
                autoPlay: false,
                disableCenter: true,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                aspectRatio: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: ActionRow(
                  tweet: widget.tweet,
                  isCarousel: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
