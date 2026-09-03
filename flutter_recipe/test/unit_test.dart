import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe/models/ingredient_model.dart';
import 'package:flutter_recipe/models/recipe_model.dart';
import 'package:flutter_recipe/models/user_model.dart';

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
  });
}
