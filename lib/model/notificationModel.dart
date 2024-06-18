class NotificationModel {
  final String label;
  final String userId;
  final String displayName;
  final String profile;
  final Map<String, dynamic> tweet;

  NotificationModel({
    required this.label,
    required this.userId,
    required this.displayName,
    required this.profile,
    required this.tweet,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      label: json['label'],
      userId: json['user_id'],
      displayName: json['display_name'],
      profile: json['profile'],
      tweet: json['tweet'],
    );
  }
}
