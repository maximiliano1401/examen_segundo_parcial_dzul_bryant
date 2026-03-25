class Game {
  final int? id;
  final String title;
  final String platform;
  final String status;
  final double rating;
  final String? genre;
  final String? imageUrl;
  final DateTime createdAt;

  Game({
    this.id,
    required this.title,
    required this.platform,
    required this.status,
    required this.rating,
    this.genre,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'status': status,
      'rating': rating,
      'genre': genre,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int?,
      title: map['title'] as String,
      platform: map['platform'] as String,
      status: map['status'] as String,
      rating: (map['rating'] as num).toDouble(),
      genre: map['genre'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Game copyWith({
    int? id,
    String? title,
    String? platform,
    String? status,
    double? rating,
    String? genre,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      genre: genre ?? this.genre,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
