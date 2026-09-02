import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  StreamSubscription<List<RecipeModel>>? _recipesSubscription;

  List<RecipeModel> _allRecipes = [];
  List<RecipeModel> _filteredRecipes = [];
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
        _allRecipes = recipesData;
        _applyFilters();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Unable to load recipes from database.';
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

  void toggleFavorite(String recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
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
      final matchesCategory = _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase();

      final queryLower = _searchQuery.trim().toLowerCase();
      final matchesTitle = recipe.title.toLowerCase().contains(queryLower) ||
          recipe.name.toLowerCase().contains(queryLower) ||
          recipe.description.toLowerCase().contains(queryLower);

      final matchesIngredient = recipe.ingredients.any(
        (ing) => ing.name.toLowerCase().contains(queryLower),
      );

      final matchesQuery = queryLower.isEmpty || matchesTitle || matchesIngredient;

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _recipesSubscription?.cancel();
    super.dispose();
  }
}
