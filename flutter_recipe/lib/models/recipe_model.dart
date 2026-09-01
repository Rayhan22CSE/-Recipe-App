import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTime; // in minutes
  final int servings;
  final String difficulty; // Easy, Medium, Hard
  final double rating;
  final String createdBy;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.rating,
    required this.createdBy,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return RecipeModel(
      id: documentId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      cookingTime: (map['cookingTime'] as num?)?.toInt() ?? 0,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      difficulty: map['difficulty'] as String? ?? 'Medium',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'rating': rating,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    List<String>? ingredients,
    List<String>? instructions,
    int? cookingTime,
    int? servings,
    String? difficulty,
    double? rating,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      rating: rating ?? this.rating,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
