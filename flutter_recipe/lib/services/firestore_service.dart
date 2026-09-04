import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // User document operations
  Future<void> createUserProfile(UserModel user) async {
    try {
      debugPrint('[FirestoreService] Creating user profile for uid: ${user.id}');
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      debugPrint('[FirestoreService] User profile created successfully for uid: ${user.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FirestoreService] createUserProfile FirebaseException: [${e.plugin}/${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreService] createUserProfile unexpected error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      debugPrint('[FirestoreService] Reading user profile for uid: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        debugPrint('[FirestoreService] User profile doc exists for uid: $uid');
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      debugPrint('[FirestoreService] User profile doc does NOT exist for uid: $uid');
      return null;
    } on FirebaseException catch (e) {
      debugPrint('[FirestoreService] getUserProfile FirebaseException: [${e.plugin}/${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreService] getUserProfile unexpected error: $e');
      rethrow;
    }
  }

  Future<void> addFavoriteToUser(String uid, String recipeId) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'favoriteIds': FieldValue.arrayUnion([recipeId]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirestoreService] addFavoriteToUser error: $e');
    }
  }

  Future<void> removeFavoriteFromUser(String uid, String recipeId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'favoriteIds': FieldValue.arrayRemove([recipeId]),
      });
    } catch (e) {
      debugPrint('[FirestoreService] removeFavoriteFromUser error: $e');
    }
  }

  Future<void> clearUserFavorites(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'favoriteIds': [],
      });
    } catch (e) {
      debugPrint('[FirestoreService] clearUserFavorites error: $e');
    }
  }

  // Real-time Recipe Stream
  Stream<List<RecipeModel>> watchRecipes() {
    return _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Fetch all recipes once
  Future<List<RecipeModel>> getRecipes() async {
    final snapshot = await _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Fetch single recipe by ID
  Future<RecipeModel?> getRecipeById(String recipeId) async {
    final doc = await _firestore.collection('recipes').doc(recipeId).get();
    if (doc.exists && doc.data() != null) {
      return RecipeModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Fetch recipes by category
  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
    final snapshot = await _firestore
        .collection('recipes')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Create a new recipe in Firestore
  Future<String> createRecipe(RecipeModel recipe) async {
    try {
      debugPrint('[FirestoreService] Creating recipe: ${recipe.name}');
      final data = recipe.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection('recipes').add(data);
      debugPrint('[FirestoreService] Recipe created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[FirestoreService] createRecipe error: $e');
      rethrow;
    }
  }

  // Update an existing recipe in Firestore
  Future<void> updateRecipe(RecipeModel recipe) async {
    try {
      debugPrint('[FirestoreService] Updating recipe: ${recipe.id}');
      final data = recipe.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('recipes').doc(recipe.id).update(data);
      debugPrint('[FirestoreService] Recipe updated successfully: ${recipe.id}');
    } catch (e) {
      debugPrint('[FirestoreService] updateRecipe error: $e');
      rethrow;
    }
  }

  // Delete a recipe from Firestore
  Future<void> deleteRecipe(String recipeId) async {
    try {
      debugPrint('[FirestoreService] Deleting recipe: $recipeId');
      await _firestore.collection('recipes').doc(recipeId).delete();
      debugPrint('[FirestoreService] Recipe deleted successfully: $recipeId');
    } catch (e) {
      debugPrint('[FirestoreService] deleteRecipe error: $e');
      rethrow;
    }
  }

  // Real-time Reviews Stream for a Recipe
  Stream<List<ReviewModel>> watchReviewsForRecipe(String recipeId) {
    return _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Submit or update a Review and recalculate rating/count
  Future<void> addOrUpdateReview(ReviewModel review) async {
    try {
      debugPrint(
          '[FirestoreService] Adding/updating review for recipe: ${review.recipeId} by user: ${review.userId}');
      final reviewRef = _firestore
          .collection('recipes')
          .doc(review.recipeId)
          .collection('reviews')
          .doc(review.userId);

      final data = review.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      await reviewRef.set(data, SetOptions(merge: true));

      // Recalculate average rating and count for recipe document
      final reviewsSnapshot = await _firestore
          .collection('recipes')
          .doc(review.recipeId)
          .collection('reviews')
          .get();

      final count = reviewsSnapshot.docs.length;
      double avg = 0.0;
      if (count > 0) {
        final total = reviewsSnapshot.docs.fold<double>(
            0.0,
            (acc, doc) =>
                acc +
                ((doc.data()['rating'] as num?)?.toDouble() ?? 0.0));
        avg = total / count;
      }

      await _firestore.collection('recipes').doc(review.recipeId).update({
        'rating': double.parse(avg.toStringAsFixed(1)),
        'reviewCount': count,
      });

      debugPrint(
          '[FirestoreService] Review saved successfully. New avg: $avg, count: $count');
    } catch (e) {
      debugPrint('[FirestoreService] addOrUpdateReview error: $e');
      rethrow;
    }
  }
}
