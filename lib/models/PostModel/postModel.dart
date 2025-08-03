class PostModel {
  final String id;
  final String user; // user ID as String
  final String? content;
  final List<String> media;
  final List<String> likes;
  final int commentsCount;
  final String? repostedFrom;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.user,
    this.content,
    required this.media,
    required this.likes,
    required this.commentsCount,
    this.repostedFrom,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] as String,
      user:
          json['user'] is Map ? json['user']['_id'] ?? '' : json['user'] ?? '',
      content: json['content'],
      media: List<String>.from(json['media'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      commentsCount: json['commentsCount'] ?? 0,
      repostedFrom: json['repostedFrom'],
      visibility: json['visibility'] ?? 'public',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'content': content,
      'media': media,
      'likes': likes,
      'commentsCount': commentsCount,
      'repostedFrom': repostedFrom,
      'visibility': visibility,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
