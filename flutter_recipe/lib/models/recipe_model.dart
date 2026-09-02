import 'package:cloud_firestore/cloud_firestore.dart';
import 'ingredient_model.dart';

class RecipeModel {
  final String id;
  final String title; // Alias for name
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int calories;
  final int preparationTime; // in minutes
  final int cookingTime; // in minutes
  final double rating;
  final int reviewCount;
  final int servings;
  final List<IngredientModel> ingredients;
  final List<String> instructions;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecipeModel({
    required this.id,
    required this.name,
    String? title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.calories = 0,
    required this.preparationTime,
    int? cookingTime,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  })  : title = title ?? name,
        cookingTime = cookingTime ?? preparationTime;

  factory RecipeModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final recipeName = (map['name'] as String?) ?? (map['title'] as String?) ?? '';
    final prepTime = (map['preparationTime'] as num?)?.toInt() ??
        (map['cookingTime'] as num?)?.toInt() ??
        0;

    // Parse ingredients safely (supports map list or string list)
    final List<IngredientModel> parsedIngredients = [];
    if (map['ingredients'] is List) {
      for (var item in map['ingredients']) {
        if (item is Map<String, dynamic>) {
          parsedIngredients.add(IngredientModel.fromMap(item));
        } else if (item is String) {
          parsedIngredients.add(
            IngredientModel(name: item, amount: 1, unit: 'item'),
          );
        }
      }
    }

    return RecipeModel(
      id: documentId,
      name: recipeName,
      title: recipeName,
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      preparationTime: prepTime,
      cookingTime: prepTime,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      ingredients: parsedIngredients,
      instructions: List<String>.from(map['instructions'] ?? []),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'calories': calories,
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'rating': rating,
      'reviewCount': reviewCount,
      'servings': servings,
      'ingredients': ingredients.map((ing) => ing.toMap()).toList(),
      'instructions': instructions,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  RecipeModel copyWith({
    String? id,
    String? name,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    int? calories,
    int? preparationTime,
    int? cookingTime,
    double? rating,
    int? reviewCount,
    int? servings,
    List<IngredientModel>? ingredients,
    List<String>? instructions,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingTime: cookingTime ?? this.cookingTime,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
