import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe/models/ingredient_model.dart';
import 'package:flutter_recipe/models/recipe_model.dart';
import 'package:flutter_recipe/models/review_model.dart';
import 'package:flutter_recipe/models/user_model.dart';
import 'package:flutter_recipe/providers/recipe_provider.dart';
import 'package:flutter_recipe/repositories/recipe_repository.dart';

void main() {
  group('UserModel Tests', () {
    test('fromMap and toMap serialize correctly', () {
      final map = {
        'name': 'Tamanna',
        'email': 'tamanna@gmail.com',
        'photoUrl': null,
        'createdAt': '2026-09-03T12:00:00Z',
      };

      final user = UserModel.fromMap(map, 'user_123');
      expect(user.id, 'user_123');
      expect(user.name, 'Tamanna');
      expect(user.email, 'tamanna@gmail.com');

      final serialized = user.toMap();
      expect(serialized['name'], 'Tamanna');
      expect(serialized['email'], 'tamanna@gmail.com');
    });
  });

  group('ReviewModel Tests', () {
    test('fromMap and toMap serialize correctly', () {
      final map = {
        'recipeId': 'rec_100',
        'userId': 'usr_200',
        'userName': 'Carlos',
        'userPhotoUrl': 'https://example.com/carlos.jpg',
        'rating': 5.0,
        'comment': 'Amazing pizza recipe!',
        'createdAt': '2026-09-04T12:00:00Z',
      };

      final review = ReviewModel.fromMap(map, 'rev_300');
      expect(review.id, 'rev_300');
      expect(review.recipeId, 'rec_100');
      expect(review.userId, 'usr_200');
      expect(review.userName, 'Carlos');
      expect(review.rating, 5.0);
      expect(review.comment, 'Amazing pizza recipe!');

      final serialized = review.toMap();
      expect(serialized['recipeId'], 'rec_100');
      expect(serialized['rating'], 5.0);
      expect(serialized['comment'], 'Amazing pizza recipe!');
    });
  });

  group('IngredientModel Tests', () {
    test('fromMap and toMap serialize correctly', () {
      final map = {
        'name': 'Paneer',
        'amount': 250.0,
        'unit': 'g',
        'imageUrl': null,
      };

      final ingredient = IngredientModel.fromMap(map);
      expect(ingredient.name, 'Paneer');
      expect(ingredient.amount, 250.0);
      expect(ingredient.unit, 'g');

      final serialized = ingredient.toMap();
      expect(serialized['name'], 'Paneer');
      expect(serialized['amount'], 250.0);
    });

    test('ingredient quantity scaling calculates correctly', () {
      final ingredient = IngredientModel(name: 'Paneer', amount: 400, unit: 'g');

      // Base servings: 2. Current servings: 4. (Double amount)
      expect(ingredient.scaledAmount(4, 2), 800.0);
      expect(ingredient.formattedAmount(4, 2), '800');

      // Base servings: 2. Current servings: 1. (Half amount)
      expect(ingredient.scaledAmount(1, 2), 200.0);
      expect(ingredient.formattedAmount(1, 2), '200');

      // Base servings: 2. Current servings: 3. (1.5x amount)
      expect(ingredient.scaledAmount(3, 2), 600.0);
      expect(ingredient.formattedAmount(3, 2), '600');
    });
  });

  group('RecipeModel Tests', () {
    test('fromMap parses recipe fields safely', () {
      final map = {
        'name': 'Butter Paneer',
        'description': 'Creamy cottage cheese curry',
        'imageUrl': 'https://example.com/paneer.jpg',
        'category': 'Lunch',
        'calories': 450,
        'preparationTime': 25,
        'rating': 4.8,
        'reviewCount': 20,
        'servings': 2,
        'ingredients': [
          {'name': 'Paneer', 'amount': 250.0, 'unit': 'g'},
          {'name': 'Butter', 'amount': 50.0, 'unit': 'g'},
        ],
        'instructions': ['Cube paneer', 'Cook gravy'],
        'createdBy': 'Chef Raj',
        'createdAt': '2026-09-01T12:00:00Z',
      };

      final recipe = RecipeModel.fromMap(map, 'doc_123');
      expect(recipe.id, 'doc_123');
      expect(recipe.name, 'Butter Paneer');
      expect(recipe.title, 'Butter Paneer');
      expect(recipe.calories, 450);
      expect(recipe.preparationTime, 25);
      expect(recipe.ingredients.length, 2);
      expect(recipe.ingredients.first.name, 'Paneer');
    });
  });

  group('Search & Category Filtering Logic', () {
    test('matches title and ingredient names correctly', () {
      final recipe = RecipeModel(
        id: '1',
        name: 'Butter Paneer',
        description: 'Rich curry',
        imageUrl: 'https://example.com/img.jpg',
        category: 'Lunch',
        preparationTime: 25,
        servings: 2,
        ingredients: [
          IngredientModel(name: 'Cottage Cheese', amount: 200, unit: 'g'),
          IngredientModel(name: 'Garlic', amount: 3, unit: 'cloves'),
        ],
        instructions: ['Cook'],
        createdBy: 'Chef',
        createdAt: DateTime.now(),
      );

      final titleMatch = recipe.name.toLowerCase().contains('paneer');
      final ingredientMatch = recipe.ingredients.any(
        (ing) => ing.name.toLowerCase().contains('garlic'),
      );

      expect(titleMatch, true);
      expect(ingredientMatch, true);
    });

    test('RecipeProvider category filtering works correctly', () async {
      final repo = MockRecipeRepository([
        RecipeModel(
          id: '1',
          name: 'Mexican Pizza',
          description: 'Pizza',
          imageUrl: '',
          category: 'Dinner',
          preparationTime: 20,
          servings: 2,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
        RecipeModel(
          id: '2',
          name: 'French Toast',
          description: 'Toast',
          imageUrl: '',
          category: 'Breakfast',
          preparationTime: 15,
          servings: 1,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
        RecipeModel(
          id: '3',
          name: 'Spicy Ramen Noodles',
          description: 'Ramen',
          imageUrl: '',
          category: 'Lunch',
          preparationTime: 15,
          servings: 1,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
      ]);

      final provider = RecipeProvider(recipeRepository: repo);
      await Future.delayed(Duration.zero);

      expect(provider.recipes.length, 3);
      expect(provider.selectedCategory, 'All');

      provider.selectCategory('Dinner');
      expect(provider.selectedCategory, 'Dinner');
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'Mexican Pizza');

      provider.selectCategory('Breakfast');
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'French Toast');

      provider.selectCategory('Lunch');
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'Spicy Ramen Noodles');

      provider.selectCategory('All');
      expect(provider.recipes.length, 3);
    });

    test('RecipeProvider search filtering is case-insensitive', () async {
      final repo = MockRecipeRepository([
        RecipeModel(
          id: '1',
          name: 'Mexican Pizza',
          description: 'Pizza',
          imageUrl: '',
          category: 'Dinner',
          preparationTime: 20,
          servings: 2,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
        RecipeModel(
          id: '2',
          name: 'French Toast',
          description: 'Toast',
          imageUrl: '',
          category: 'Breakfast',
          preparationTime: 15,
          servings: 1,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
      ]);

      final provider = RecipeProvider(recipeRepository: repo);
      await Future.delayed(Duration.zero);

      provider.searchRecipes('pizza');
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'Mexican Pizza');

      provider.searchRecipes('FRENCH');
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'French Toast');

      provider.searchRecipes('');
      expect(provider.recipes.length, 2);
    });

    test('RecipeProvider search and category filter work together', () async {
      final repo = MockRecipeRepository([
        RecipeModel(
          id: '1',
          name: 'Mexican Pizza',
          description: 'Pizza',
          imageUrl: '',
          category: 'Dinner',
          preparationTime: 20,
          servings: 2,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
        RecipeModel(
          id: '2',
          name: 'French Toast',
          description: 'Toast',
          imageUrl: '',
          category: 'Breakfast',
          preparationTime: 15,
          servings: 1,
          ingredients: [],
          instructions: [],
          createdBy: 'User',
          createdAt: DateTime.now(),
        ),
      ]);

      final provider = RecipeProvider(recipeRepository: repo);
      await Future.delayed(Duration.zero);

      provider.selectCategory('Dinner');
      provider.searchRecipes('Pizza');
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'Mexican Pizza');

      provider.selectCategory('Breakfast');
      expect(provider.recipes.length, 0);

      provider.clearFilters();
      expect(provider.selectedCategory, 'All');
      expect(provider.searchQuery, '');
      expect(provider.recipes.length, 2);
    });

    test('RecipeProvider addRecipe, updateRecipe, deleteRecipe work correctly', () async {
      final repo = MockRecipeRepository([
        RecipeModel(
          id: '1',
          name: 'Original Recipe',
          description: 'Desc',
          imageUrl: '',
          category: 'Dinner',
          preparationTime: 20,
          servings: 2,
          ingredients: [],
          instructions: [],
          createdBy: 'user_1',
          createdAt: DateTime.now(),
        ),
      ]);

      final provider = RecipeProvider(recipeRepository: repo);
      await Future.delayed(Duration.zero);
      expect(provider.recipes.length, 1);

      final newRecipe = RecipeModel(
        id: '',
        name: 'New Pasta',
        description: 'Delicious pasta',
        imageUrl: '',
        category: 'Lunch',
        preparationTime: 15,
        servings: 2,
        ingredients: [],
        instructions: ['Boil pasta'],
        createdBy: 'user_1',
        createdAt: DateTime.now(),
      );

      final addSuccess = await provider.addRecipe(newRecipe);
      expect(addSuccess, true);

      final updated = provider.recipes.first.copyWith(name: 'Updated Original Recipe');
      final updateSuccess = await provider.updateRecipe(updated);
      expect(updateSuccess, true);

      final deleteSuccess = await provider.deleteRecipe('1');
      expect(deleteSuccess, true);
    });

    test('RecipeProvider submitReview works correctly', () async {
      final repo = MockRecipeRepository([]);
      final provider = RecipeProvider(recipeRepository: repo);

      final review = ReviewModel(
        id: 'rev_1',
        recipeId: 'rec_1',
        userId: 'usr_1',
        userName: 'Tamanna',
        rating: 5.0,
        comment: 'Super tasty recipe!',
        createdAt: DateTime.now(),
      );

      final success = await provider.submitReview(review);
      expect(success, true);
    });
  });
}

class MockRecipeRepository extends RecipeRepository {
  final List<RecipeModel> mockRecipes;
  final List<ReviewModel> mockReviews = [];

  MockRecipeRepository(this.mockRecipes);

  @override
  Stream<List<RecipeModel>> watchRecipes() {
    return Stream.value(mockRecipes);
  }

  @override
  Future<String> createRecipe(RecipeModel recipe) async {
    final newId = 'created_${mockRecipes.length + 1}';
    mockRecipes.add(recipe.copyWith(id: newId));
    return newId;
  }

  @override
  Future<void> updateRecipe(RecipeModel recipe) async {
    final index = mockRecipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      mockRecipes[index] = recipe;
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    mockRecipes.removeWhere((r) => r.id == recipeId);
  }

  @override
  Stream<List<ReviewModel>> watchReviewsForRecipe(String recipeId) {
    return Stream.value(mockReviews.where((r) => r.recipeId == recipeId).toList());
  }

  @override
  Future<void> addOrUpdateReview(ReviewModel review) async {
    final index = mockReviews.indexWhere((r) => r.recipeId == review.recipeId && r.userId == review.userId);
    if (index != -1) {
      mockReviews[index] = review;
    } else {
      mockReviews.add(review);
    }
  }
}
