import 'package:anony_tweet/helpers/storage.dart';
import 'package:anony_tweet/model/tweet.dart';
import 'package:anony_tweet/screen/photo_carousel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TweetMediaGrid extends StatelessWidget {
  final Tweet tweet;

  const TweetMediaGrid({super.key, required this.tweet, required List<String> images});

  @override
  Widget build(BuildContext context) {
    final images = tweet.media;

    var imageWidth = (MediaQuery.of(context).size.width - 32 - 60) /
            (images.length > 1 ? 2 : 1) -
        (images.length == 1 ? 1 : images.length / 2 * 1);

    if (images.length.isEven) {
      return SizedBox(
        height: 200,
        child: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              childAspectRatio: imageWidth / (images.length == 2 ? 200 : 100),
              children: images
                  .map(
                    (image) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoCarouselScreen(
                              tweet: tweet,
                              selected: image.toString(),
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: image.toString(),
                        child: CachedNetworkImage(
                          imageUrl:
                              getImageUrl("tweet_medias", image.toString())
                                  .toString(),
                          width: imageWidth,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCarouselScreen(
                        tweet: tweet,
                        selected: images[0].toString(),
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: images[0].toString(),
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl("tweet_medias", images[0].toString())
                        .toString(),
                    height: images.length > 1 ? 200 : null,
                    width: imageWidth,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              if (images.length > 1)
                SizedBox(
                  width: 2,
                ),
              if (images.length > 1)
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoCarouselScreen(
                              tweet: tweet,
                              selected: images[1].toString(),
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: images[1].toString(),
                        child: CachedNetworkImage(
                          imageUrl:
                              getImageUrl("tweet_medias", images[1].toString())
                                  .toString(),
                          height: 99,
                          width: imageWidth,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoCarouselScreen(
                              tweet: tweet,
                              selected: images[2].toString(),
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: images[2].toString(),
                        child: CachedNetworkImage(
                          imageUrl:
                              getImageUrl("tweet_medias", images[2].toString())
                                  .toString(),
                          height: 99,
                          width: imageWidth,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      );
    }
  }
}
