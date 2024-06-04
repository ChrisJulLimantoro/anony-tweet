import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikeButtonBloc extends Cubit<List> {
  final String userId;
  final String tweetId;
  final client = Supabase.instance.client;

  LikeButtonBloc({
    required int likeCount, 
    required bool isLiked,
    required this.userId,
    required this.tweetId,
  }) : super([likeCount, isLiked]);

  void toggle() async {
    bool isCurrentlyLiked = state[1];
    int currentLikeCount = state[0];

    if (isCurrentlyLiked) {
      emit([currentLikeCount - 1, false]);
      await _removeLikeFromDatabase();
    } else {
      emit([currentLikeCount + 1, true]);
      await _addLikeToDatabase();
    }
  }

  Future<void> _addLikeToDatabase() async {
    var response = await client.from('likes').insert({
      'user_id': userId,
      'tweet_id': tweetId,
    });
  }

  Future<void> _removeLikeFromDatabase() async {
    var response = await client.from('likes').delete().match({
      'user_id': userId,
      'tweet_id': tweetId,
    });
  }
}
