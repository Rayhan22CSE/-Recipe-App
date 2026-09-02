import '../models/recipe_model.dart';
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
}
