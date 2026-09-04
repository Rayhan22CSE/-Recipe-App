import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';

class AppConstants {
  static const String appName = 'Recipe Haven';
  static const String appTagline = 'Discover & Cook Amazing Recipes';

  // Categories matching reference design
  static const List<Map<String, String>> categories = [
    {'name': 'All', 'icon': 'restaurant'},
    {'name': 'Dinner', 'icon': 'dinner_dining'},
    {'name': 'Lunch', 'icon': 'lunch_dining'},
    {'name': 'Breakfast', 'icon': 'free_breakfast'},
  ];

  // Reference recipes dataset
  static final List<RecipeModel> testFallbackRecipes = [
    RecipeModel(
      id: 'ref_1',
      name: 'Mexican Pizza',
      description:
          'Crispy tortilla pizza topped with seasoned beans, melted cheese, black olives, green onions, sour cream, and fresh diced tomatoes.',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80',
      category: 'Dinner',
      calories: 140,
      preparationTime: 25,
      servings: 2,
      rating: 0.0,
      reviewCount: 0,
      ingredients: [
        IngredientModel(name: 'Tortilla Shells', amount: 2, unit: 'pcs'),
        IngredientModel(name: 'Refried Beans', amount: 150, unit: 'gm'),
        IngredientModel(name: 'Shredded Cheese', amount: 100, unit: 'gm'),
        IngredientModel(name: 'Sliced Olives', amount: 30, unit: 'gm'),
        IngredientModel(name: 'Sour Cream', amount: 2, unit: 'tbsp'),
      ],
      instructions: [
        'Crisp tortilla shells in oven at 200°C for 5 minutes.',
        'Spread refried beans and shredded cheese over tortillas.',
        'Bake until cheese is melted and bubbling.',
        'Top with diced tomatoes, black olives, green onions, and sour cream.'
      ],
      createdBy: 'Chef Carlos',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecipeModel(
      id: 'ref_2',
      name: 'French Toast',
      description:
          'Golden brioche slices dipped in cinnamon egg custard, toasted to perfection and topped with fresh strawberries and blueberries.',
      imageUrl:
          'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=600&q=80',
      category: 'Breakfast',
      calories: 110,
      preparationTime: 15,
      servings: 1,
      rating: 0.0,
      reviewCount: 0,
      ingredients: [
        IngredientModel(name: 'Brioche Bread', amount: 2, unit: 'slices'),
        IngredientModel(name: 'Fresh Eggs', amount: 2, unit: 'pcs'),
        IngredientModel(name: 'Whole Milk', amount: 50, unit: 'gm'),
        IngredientModel(name: 'Fresh Berries', amount: 100, unit: 'gm'),
      ],
      instructions: [
        'Whisk eggs, milk, cinnamon, and vanilla extract in a bowl.',
        'Dip bread slices into mixture until fully coated.',
        'Cook in a buttered skillet over medium heat until golden brown on both sides.',
        'Garnish with fresh strawberries and blueberries before serving.'
      ],
      createdBy: 'Baker Sarah',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    RecipeModel(
      id: 'ref_3',
      name: 'Spicy Ramen Noodles',
      description:
          'Rich savory ramen broth with chewy noodles, soft-boiled eggs, tender beef, scallions, and chili oil.',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
      category: 'Lunch',
      calories: 120,
      preparationTime: 15,
      servings: 1,
      rating: 0.0,
      reviewCount: 0,
      ingredients: [
        IngredientModel(
          name: 'Noodles',
          amount: 200,
          unit: 'gm',
          imageUrl:
              'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=200&q=80',
        ),
        IngredientModel(
          name: 'Egg',
          amount: 180,
          unit: 'gm',
          imageUrl:
              'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&q=80',
        ),
        IngredientModel(
          name: 'Mead & Vegetables',
          amount: 150,
          unit: 'gm',
          imageUrl:
              'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=200&q=80',
        ),
      ],
      instructions: [
        'Boil ramen noodles in savory broth for 3 minutes.',
        'Soft boil eggs for 6 minutes and halve.',
        'Arrange noodles, soft-boiled eggs, beef, and vegetables in bowl.',
        'Drizzle with chili oil and sprinkle fresh scallions.'
      ],
      createdBy: 'Chef Kenji',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];
}
