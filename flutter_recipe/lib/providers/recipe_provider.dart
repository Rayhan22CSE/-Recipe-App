import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../models/review_model.dart';
import '../repositories/recipe_repository.dart';
import '../utils/constants.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  StreamSubscription<List<RecipeModel>>? _recipesSubscription;

  List<RecipeModel> _allRecipes = AppConstants.testFallbackRecipes;
  List<RecipeModel> _filteredRecipes = AppConstants.testFallbackRecipes;
  final Set<String> _favoriteIds = {};
  final Map<String, int> _servingsMap = {};

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  RecipeProvider({RecipeRepository? recipeRepository})
    : _recipeRepository = recipeRepository ?? RecipeRepository() {
    _init();
  }

  List<RecipeModel> get recipes => _filteredRecipes;
  List<RecipeModel> get allRecipes => _allRecipes;
  List<RecipeModel> get featuredRecipes => _allRecipes.take(2).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Set<String> get favoriteIds => _favoriteIds;

  void _init() {
    _listenToRecipes();
  }

  void _listenToRecipes() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _recipesSubscription?.cancel();
    _recipesSubscription = _recipeRepository.watchRecipes().listen(
      (recipesData) {
        _allRecipes = recipesData.isNotEmpty
            ? recipesData
            : AppConstants.testFallbackRecipes;
        _applyFilters();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _allRecipes = AppConstants.testFallbackRecipes;
        _applyFilters();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  Future<void> refreshRecipes() async {
    _listenToRecipes();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void searchRecipes(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void syncUserFavorites(List<String> userFavoriteIds) {
    _favoriteIds.clear();
    _favoriteIds.addAll(userFavoriteIds);
    notifyListeners();
  }

  void toggleFavorite(String recipeId, {String? userId}) {
    final isFav = _favoriteIds.contains(recipeId);
    if (isFav) {
      _favoriteIds.remove(recipeId);
      if (userId != null && userId.isNotEmpty) {
        _recipeRepository.removeFavoriteFromUser(userId, recipeId);
      }
    } else {
      _favoriteIds.add(recipeId);
      if (userId != null && userId.isNotEmpty) {
        _recipeRepository.addFavoriteToUser(userId, recipeId);
      }
    }
    notifyListeners();
  }

  Future<void> clearAllFavorites({String? userId}) async {
    _favoriteIds.clear();
    if (userId != null && userId.isNotEmpty) {
      await _recipeRepository.clearUserFavorites(userId);
    }
    notifyListeners();
  }

  bool isFavorite(String recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  // Servings Scaling Logic for Recipe Details
  int getServings(String recipeId, int baseServings) {
    return _servingsMap[recipeId] ?? (baseServings > 0 ? baseServings : 1);
  }

  void incrementServings(String recipeId, int baseServings) {
    final current = getServings(recipeId, baseServings);
    _servingsMap[recipeId] = current + 1;
    notifyListeners();
  }

  void decrementServings(String recipeId, int baseServings) {
    final current = getServings(recipeId, baseServings);
    if (current > 1) {
      _servingsMap[recipeId] = current - 1;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredRecipes = _allRecipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase();

      final queryLower = _searchQuery.trim().toLowerCase();
      final matchesTitle =
          recipe.title.toLowerCase().contains(queryLower) ||
          recipe.name.toLowerCase().contains(queryLower) ||
          recipe.description.toLowerCase().contains(queryLower);

      final matchesIngredient = recipe.ingredients.any(
        (ing) => ing.name.toLowerCase().contains(queryLower),
      );

      final matchesQuery =
          queryLower.isEmpty || matchesTitle || matchesIngredient;

      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Recipe Management (CRUD) Methods
  Future<bool> addRecipe(RecipeModel recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docId = await _recipeRepository.createRecipe(recipe);
      debugPrint('[RecipeProvider] addRecipe succeeded with doc ID: $docId');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[RecipeProvider] addRecipe failed: $e');
      _errorMessage = 'Failed to add recipe. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecipe(RecipeModel recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recipeRepository.updateRecipe(recipe);
      debugPrint(
        '[RecipeProvider] updateRecipe succeeded for ID: ${recipe.id}',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[RecipeProvider] updateRecipe failed: $e');
      _errorMessage = 'Failed to update recipe. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recipeRepository.deleteRecipe(recipeId);
      debugPrint('[RecipeProvider] deleteRecipe succeeded for ID: $recipeId');
      _allRecipes.removeWhere((r) => r.id == recipeId);
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[RecipeProvider] deleteRecipe failed: $e');
      _errorMessage = 'Failed to delete recipe. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Real-Time Review Operations
  Stream<List<ReviewModel>> watchReviews(String recipeId) {
    return _recipeRepository.watchReviewsForRecipe(recipeId);
  }

  Future<bool> submitReview(ReviewModel review) async {
    try {
      await _recipeRepository.addOrUpdateReview(review);
      return true;
    } catch (e) {
      debugPrint('[RecipeProvider] submitReview error: $e');
      _errorMessage = 'Failed to submit review. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _recipesSubscription?.cancel();
    super.dispose();
  }
}
