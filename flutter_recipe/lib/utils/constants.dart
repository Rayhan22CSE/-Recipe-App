import '../models/recipe_model.dart';

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

  // Mock Recipes for UI Development
  static final List<RecipeModel> mockRecipes = [
    RecipeModel(
      id: 'mock_1',
      title: 'Creamy Garlic Butter Pasta',
      description:
          'A quick, silky pasta dish infused with rich garlic butter, fresh parsley, and parmesan cheese.',
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3d5d6281313?w=600&q=80',
      category: 'Lunch',
      ingredients: [
        '250g Fettuccine pasta',
        '4 cloves garlic, minced',
        '50g unsalted butter',
        '1/2 cup heavy cream',
        '1/2 cup grated Parmesan',
        'Salt & black pepper to taste',
        'Fresh parsley for garnish'
      ],
      instructions: [
        'Boil pasta in salted water until al dente.',
        'Melt butter in a skillet and sauté minced garlic until fragrant.',
        'Pour in heavy cream and simmer for 2 minutes.',
        'Stir in grated Parmesan until sauce is smooth.',
        'Toss in cooked pasta, garnish with fresh parsley, and serve warm.'
      ],
      cookingTime: 20,
      servings: 2,
      difficulty: 'Easy',
      rating: 4.8,
      createdBy: 'Chef Alex',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RecipeModel(
      id: 'mock_2',
      title: 'Avocado Toast with Poached Egg',
      description:
          'Crispy sourdough bread topped with creamy mashed avocado, chili flakes, and a golden poached egg.',
      imageUrl:
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
      category: 'Breakfast',
      ingredients: [
        '2 slices sourdough bread',
        '1 ripe avocado',
        '2 fresh eggs',
        '1 tbsp lemon juice',
        'Red pepper flakes',
        'Salt and pepper'
      ],
      instructions: [
        'Toast the sourdough bread slices until golden crisp.',
        'Mash avocado with lemon juice, salt, and pepper in a small bowl.',
        'Poach eggs in simmering water with a splash of vinegar for 3 minutes.',
        'Spread mashed avocado onto toast, top with poached egg and red pepper flakes.'
      ],
      cookingTime: 15,
      servings: 2,
      difficulty: 'Easy',
      rating: 4.7,
      createdBy: 'Maria Chef',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    RecipeModel(
      id: 'mock_3',
      title: 'Grilled Salmon with Asparagus',
      description:
          'Tender, flaky salmon fillet grilled to perfection, served with lemon herb roasted asparagus.',
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600&q=80',
      category: 'Dinner',
      ingredients: [
        '2 fresh salmon fillets',
        '1 bunch fresh asparagus',
        '2 tbsp olive oil',
        '1 lemon, sliced',
        '1 tsp garlic powder',
        'Fresh dill and sea salt'
      ],
      instructions: [
        'Preheat grill or oven to 200°C (400°F).',
        'Season salmon fillets with olive oil, garlic powder, salt, and pepper.',
        'Toss asparagus in olive oil and arrange around salmon with lemon slices.',
        'Grill/bake for 14-16 minutes until salmon flakes easily with a fork.'
      ],
      cookingTime: 25,
      servings: 2,
      difficulty: 'Medium',
      rating: 4.9,
      createdBy: 'Chef Gordon',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecipeModel(
      id: 'mock_4',
      title: 'Berry Berry Pancakes',
      description:
          'Fluffy golden pancakes stacked high with fresh strawberries, blueberries, and maple syrup.',
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600&q=80',
      category: 'Breakfast',
      ingredients: [
        '1.5 cups flour',
        '1 cup milk',
        '1 egg',
        '2 tbsp sugar',
        '1 tbsp baking powder',
        'Fresh berries & maple syrup'
      ],
      instructions: [
        'Whisk flour, sugar, and baking powder in a bowl.',
        'In corporate milk and egg until a smooth batter forms.',
        'Pour ladlefuls onto a warm buttered skillet and cook until bubbly.',
        'Flip and cook for another 1-2 minutes.',
        'Serve stacked with fresh berries and warm maple syrup.'
      ],
      cookingTime: 20,
      servings: 4,
      difficulty: 'Easy',
      rating: 4.6,
      createdBy: 'Baker Sarah',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
