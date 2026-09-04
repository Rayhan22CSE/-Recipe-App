import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ReviewModel(
      id: documentId,
      recipeId: map['recipeId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Anonymous',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? recipeId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
