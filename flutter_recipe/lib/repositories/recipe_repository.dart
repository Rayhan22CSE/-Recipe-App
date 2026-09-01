import '../models/recipe_model.dart';
import '../utils/constants.dart';
import '../services/firestore_service.dart';

class RecipeRepository {
  final FirestoreService _firestoreService;

  RecipeRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<RecipeModel>> getMockRecipes() async {
    // Simulate minor network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return AppConstants.mockRecipes;
  }

  Stream<List<RecipeModel>> getFirestoreRecipes() {
    return _firestoreService.getRecipesStream();
  }
}
