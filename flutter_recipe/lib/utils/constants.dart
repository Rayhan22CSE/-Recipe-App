import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';

class AppConstants {
  static const String appName = 'Recipe Haven';
  static const String appTagline = 'Discover & Cook Amazing Recipes';

  // Categories
  static const List<Map<String, String>> categories = [
    {'name': 'All', 'icon': 'restaurant'},
    {'name': 'Breakfast', 'icon': 'free_breakfast'},
    {'name': 'Lunch', 'icon': 'lunch_dining'},
    {'name': 'Dinner', 'icon': 'dinner_dining'},
    {'name': 'Dessert', 'icon': 'icecream'},
    {'name': 'Quick & Easy', 'icon': 'timer'},
  ];

  // Isolated Mock Recipes for test/fallback reference
  static final List<RecipeModel> testFallbackRecipes = [
    RecipeModel(
      id: 'mock_1',
      name: 'Creamy Garlic Butter Pasta',
      description:
          'A quick, silky pasta dish infused with rich garlic butter, fresh parsley, and parmesan cheese.',
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3d5d6281313?w=600&q=80',
      category: 'Lunch',
      calories: 420,
      preparationTime: 20,
      servings: 2,
      rating: 4.8,
      reviewCount: 12,
      ingredients: [
        IngredientModel(name: 'Fettuccine Pasta', amount: 250, unit: 'g'),
        IngredientModel(name: 'Minced Garlic', amount: 4, unit: 'cloves'),
        IngredientModel(name: 'Unsalted Butter', amount: 50, unit: 'g'),
        IngredientModel(name: 'Heavy Cream', amount: 0.5, unit: 'cup'),
        IngredientModel(name: 'Grated Parmesan', amount: 0.5, unit: 'cup'),
      ],
      instructions: [
        'Boil pasta in salted water until al dente.',
        'Melt butter in a skillet and sauté minced garlic until fragrant.',
        'Pour in heavy cream and simmer for 2 minutes.',
        'Stir in grated Parmesan until sauce is smooth.',
        'Toss in cooked pasta, garnish with fresh parsley, and serve warm.'
      ],
      createdBy: 'Chef Alex',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RecipeModel(
      id: 'mock_2',
      name: 'Avocado Toast with Poached Egg',
      description:
          'Crispy sourdough bread topped with creamy mashed avocado, chili flakes, and a golden poached egg.',
      imageUrl:
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
      category: 'Breakfast',
      calories: 310,
      preparationTime: 15,
      servings: 1,
      rating: 4.7,
      reviewCount: 19,
      ingredients: [
        IngredientModel(name: 'Sourdough Bread', amount: 2, unit: 'slices'),
        IngredientModel(name: 'Ripe Avocado', amount: 1, unit: 'pc'),
        IngredientModel(name: 'Fresh Eggs', amount: 2, unit: 'pcs'),
        IngredientModel(name: 'Lemon Juice', amount: 1, unit: 'tbsp'),
      ],
      instructions: [
        'Toast the sourdough bread slices until golden crisp.',
        'Mash avocado with lemon juice, salt, and pepper in a small bowl.',
        'Poach eggs in simmering water with a splash of vinegar for 3 minutes.',
        'Spread mashed avocado onto toast, top with poached egg and red pepper flakes.'
      ],
      createdBy: 'Maria Chef',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}
