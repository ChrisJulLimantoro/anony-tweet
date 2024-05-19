import 'package:anony_tweet/blocs/like_button_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LikeButtonBloc, List>(
      builder: (context, state) {
        // debugPrint(state.toString());
        
        return GestureDetector(
          onTap: () {
            context.read<LikeButtonBloc>().toggle();
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state[1] ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: state[1] ? Colors.red : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text("${state[0]}"),
            ],
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}
