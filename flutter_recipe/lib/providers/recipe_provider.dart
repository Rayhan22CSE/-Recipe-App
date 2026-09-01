import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _recipeRepository;

  List<RecipeModel> _allRecipes = [];
  List<RecipeModel> _filteredRecipes = [];
  final Set<String> _favoriteIds = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  RecipeProvider({RecipeRepository? recipeRepository})
      : _recipeRepository = recipeRepository ?? RecipeRepository() {
    loadRecipes();
  }

  List<RecipeModel> get recipes => _filteredRecipes;
  List<RecipeModel> get featuredRecipes => _allRecipes.take(2).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Set<String> get favoriteIds => _favoriteIds;

  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allRecipes = await _recipeRepository.getMockRecipes();
      _applyFilters();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load recipes.';
      _isLoading = false;
    }
    notifyListeners();
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

  void _applyFilters() {
    _filteredRecipes = _allRecipes.where((recipe) {
      final matchesCategory = _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.ingredients.any(
              (ing) => ing.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesQuery;
    }).toList();
  }
}
