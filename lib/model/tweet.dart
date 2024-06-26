class Tweet {
  String id;
  String username;
  String profilePicture;
  bool verified;
  String createdAt;
  String content;
  List<String> media;
  int like;
  int retweet;
  int comment;
  int view;
  bool isLiked;
  bool isReTweet;
  bool isComment;
  String oriCreator;
  bool isRetweetedByUser;
  String? commentId;

  Tweet({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.verified,
    required this.createdAt,
    required this.content,
    required this.media,
    required this.like,
    required this.retweet,
    required this.comment,
    required this.view,
    required this.isLiked,
    required this.isReTweet,
    this.isComment = false,
    required this.oriCreator,
    required this.isRetweetedByUser,
    this.commentId,
  });
}
