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

  // Prepared methods for recipe operations (for future phases)
  Stream<List<RecipeModel>> getRecipesStream() {
    return _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    await _firestore.collection('recipes').add(recipe.toMap());
  }
}
