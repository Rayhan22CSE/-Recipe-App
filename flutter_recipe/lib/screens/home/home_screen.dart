import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_card.dart';
import '../../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'Foodie';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await recipeProvider.loadRecipes();
          },
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header / User Greeting & Profile Avatar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hello, $userName 👋',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What would you like to cook today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            size: 20, color: AppTheme.primaryColor),
                      ),
                      onPressed: () async {
                        await authProvider.logout();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Interactive Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      recipeProvider.searchRecipes(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipes, ingredients...',
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: Color(0xFF757575)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: Color(0xFF757575)),
                              onPressed: () {
                                _searchController.clear();
                                recipeProvider.searchRecipes('');
                              },
                            )
                          : Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.tune_rounded,
                                  color: Colors.white, size: 18),
                            ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Horizontal Categories Selector
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.categories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.categories[index];
                      final name = category['name']!;
                      final icon = category['icon']!;
                      final isSelected =
                          recipeProvider.selectedCategory == name;

                      return CategoryCard(
                        title: name,
                        iconName: icon,
                        isSelected: isSelected,
                        onTap: () {
                          recipeProvider.selectCategory(name);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Featured Recipe Hero Carousel (Only shown when not searching)
                if (recipeProvider.searchQuery.isEmpty &&
                    recipeProvider.selectedCategory == 'All') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Recipes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recipeProvider.featuredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipeProvider.featuredRecipes[index];
                        final isFav = recipeProvider.isFavorite(recipe.id);

                        return RecipeCard(
                          recipe: recipe,
                          isCompact: true,
                          isFavorite: isFav,
                          onFavoriteToggle: () {
                            recipeProvider.toggleFavorite(recipe.id);
                          },
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.recipeDetails,
                              arguments: recipe,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Popular / All Recipes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipeProvider.selectedCategory == 'All'
                          ? 'Popular Recipes'
                          : '${recipeProvider.selectedCategory} Recipes',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${recipeProvider.recipes.length} found',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (recipeProvider.recipes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'No recipes found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try searching for another category or recipe title.',
                          style: TextStyle(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipeProvider.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipeProvider.recipes[index];
                      final isFav = recipeProvider.isFavorite(recipe.id);

                      return RecipeCard(
                        recipe: recipe,
                        isCompact: false,
                        isFavorite: isFav,
                        onFavoriteToggle: () {
                          recipeProvider.toggleFavorite(recipe.id);
                        },
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recipeDetails,
                            arguments: recipe,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.search);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.favorites);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
        indicatorColor: AppTheme.primaryColor.withAlpha(40),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon:
                Icon(Icons.favorite_rounded, color: AppTheme.primaryColor),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
