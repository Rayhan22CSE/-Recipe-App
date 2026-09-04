import '../models/recipe_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

class RecipeRepository {
  final FirestoreService _firestoreService;

  RecipeRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<RecipeModel>> watchRecipes() {
    return _firestoreService.watchRecipes();
  }

  Future<List<RecipeModel>> getRecipes() async {
    return await _firestoreService.getRecipes();
  }

  Future<RecipeModel?> getRecipeById(String recipeId) async {
    return await _firestoreService.getRecipeById(recipeId);
  }

  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
    return await _firestoreService.getRecipesByCategory(category);
  }

  Future<String> createRecipe(RecipeModel recipe) async {
    return await _firestoreService.createRecipe(recipe);
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    await _firestoreService.updateRecipe(recipe);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestoreService.deleteRecipe(recipeId);
  }

  Stream<List<ReviewModel>> watchReviewsForRecipe(String recipeId) {
    return _firestoreService.watchReviewsForRecipe(recipeId);
  }

  Future<void> addOrUpdateReview(ReviewModel review) async {
    await _firestoreService.addOrUpdateReview(review);
  }

  Future<void> addFavoriteToUser(String uid, String recipeId) async {
    await _firestoreService.addFavoriteToUser(uid, recipeId);
  }

  Future<void> removeFavoriteFromUser(String uid, String recipeId) async {
    await _firestoreService.removeFavoriteFromUser(uid, recipeId);
  }

  Future<void> clearUserFavorites(String uid) async {
    await _firestoreService.clearUserFavorites(uid);
  }
}
