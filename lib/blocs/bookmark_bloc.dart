import 'package:flutter_bloc/flutter_bloc.dart';

class BookmarkBloc extends Cubit<bool> {
  BookmarkBloc(bool isBookmarked) : super(isBookmarked);

  void toggle() => emit(!state);
}
