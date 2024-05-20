import 'package:flutter_bloc/flutter_bloc.dart';

class LikeButtonBloc extends Cubit<List> {
  LikeButtonBloc(int likeCount, bool isLiked) : super([likeCount, isLiked]);

  void toggle() {
    emit([!state[1] ? state[0] + 1 : state[0] - 1, !state[1]]);
  }

  // Stream<List> mapEventToState(event) async* {
  //   if (event == "toggle") {
  //     _likeCount = _isLiked ? _likeCount - 1 : _likeCount + 1;
  //     _isLiked = !_isLiked;
  //     yield [_likeCount, _isLiked];
  //   } else {
  //     yield [_likeCount, _isLiked];
  //   }
  // }
}
