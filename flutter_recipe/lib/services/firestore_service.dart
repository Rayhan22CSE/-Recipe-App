import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
