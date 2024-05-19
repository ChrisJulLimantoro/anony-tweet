import 'package:anony_tweet/blocs/bookmark_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness theme = MediaQuery.of(context).platformBrightness;

    return BlocConsumer<BookmarkBloc, bool>(
      builder: (context, state) {
        // debugPrint("after bloc: $state");
        return GestureDetector(
          onTap: () {
            context.read<BookmarkBloc>().toggle();
          },
          child: Row(
            children: [
              Icon(
                state ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                color: state
                    ? (theme == Brightness.light ? Colors.black : Colors.white)
                    : Colors.grey,
                size: 16,
              ),
            ],
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}
