import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/recipe_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmClearAll(BuildContext context, RecipeProvider recipeProvider, String? userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Favorites?'),
        content: const Text(
            'Are you sure you want to remove all saved recipes from your favorites list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              recipeProvider.clearAllFavorites(userId: userId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cleared all saved favorites.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    // Filter recipes that are favorited
    final allFavs = recipeProvider.recipes
        .where((r) => recipeProvider.isFavorite(r.id))
        .toList();

    // Apply local search and category filter within favorites
    final filteredFavs = allFavs.where((recipe) {
      final matchesCategory = _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase();
      final queryLower = _searchQuery.trim().toLowerCase();
      final matchesQuery = queryLower.isEmpty ||
          recipe.name.toLowerCase().contains(queryLower) ||
          recipe.title.toLowerCase().contains(queryLower) ||
          recipe.category.toLowerCase().contains(queryLower);
      return matchesCategory && matchesQuery;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1100
        ? 4
        : (screenWidth >= 650 ? 3 : 2);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Color(0xFF1E1E24),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (allFavs.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.redAccent, size: 20),
              label: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPressed: () => _confirmClearAll(context, recipeProvider, userId),
            ),
        ],
      ),
      body: SafeArea(
        child: allFavs.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Favorites Saved Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the heart icon on any recipe card to save your top dishes here for quick access anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A94A6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.explore);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.explore_outlined,
                            color: Colors.white, size: 20),
                        label: const Text(
                          'Discover Recipes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Favorites Search Bar Input
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search inside my favorites...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9EA6B5),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Color(0xFF9EA6B5), size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.cancel_rounded,
                                      color: Colors.grey, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Filter Chips Row
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.categories.length,
                        itemBuilder: (context, index) {
                          final category = AppConstants.categories[index];
                          final name = category['name']!;
                          final icon = category['icon']!;
                          final isSelected = _selectedCategory == name;

                          return CategoryCard(
                            title: name,
                            iconName: icon,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCategory = name;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Saved Counter Header
                    Text(
                      'Saved (${filteredFavs.length} of ${allFavs.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filtered Grid View
                    if (filteredFavs.isEmpty)
                      EmptyState(
                        title: 'No Matching Favorites',
                        description:
                            'No saved recipes match "$_searchQuery" in category "$_selectedCategory".',
                        icon: Icons.search_off_rounded,
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.08,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredFavs.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredFavs[index];
                          return RecipeCard(
                            recipe: recipe,
                            isFavorite: true,
                            onFavoriteToggle: () {
                              recipeProvider.toggleFavorite(recipe.id,
                                  userId: userId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Removed "${recipe.name.isNotEmpty ? recipe.name : recipe.title}" from favorites'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: AppTheme.secondaryColor,
                                    onPressed: () {
                                      recipeProvider.toggleFavorite(recipe.id,
                                          userId: userId);
                                    },
                                  ),
                                ),
                              );
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
    );
  }
}
