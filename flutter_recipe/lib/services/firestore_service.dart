import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User document operations
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
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
