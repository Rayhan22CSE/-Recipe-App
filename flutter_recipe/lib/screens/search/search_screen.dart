import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final displayRecipes = recipeProvider.recipes;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'All Recipes & Search',
          style: TextStyle(
            color: Color(0xFF1E1E24),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E24)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded, color: AppTheme.primaryColor),
            tooltip: 'Clear Filters',
            onPressed: () {
              _searchController.clear();
              recipeProvider.clearFilters();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await recipeProvider.refreshRecipes();
          },
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      recipeProvider.searchRecipes(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipes by name or ingredient...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9EA6B5),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF9EA6B5), size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded,
                                  color: Colors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                recipeProvider.searchRecipes('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Chips Selector
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.categories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.categories[index];
                      final name = category['name']!;
                      final icon = category['icon']!;
                      final isSelected = recipeProvider.selectedCategory == name;

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
                const SizedBox(height: 20),

                // Recipe Counter Header
                Text(
                  'Showing ${displayRecipes.length} recipes',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E24),
                  ),
                ),
                const SizedBox(height: 14),

                // Grid View of Filtered Recipes
                if (recipeProvider.isLoading)
                  const LoadingWidget(message: 'Loading recipes...')
                else if (displayRecipes.isEmpty)
                  const EmptyState(
                    title: 'No Recipes Found',
                    description: 'Try searching for something else or clearing filters.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 165,
                      mainAxisExtent: 175,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: displayRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = displayRecipes[index];
                      final isFav = recipeProvider.isFavorite(recipe.id);

                      return Center(
                        child: RecipeCard(
                          recipe: recipe,
                          width: 155,
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
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
