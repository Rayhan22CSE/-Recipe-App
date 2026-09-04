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
    final recipeProvider = Provider.of<RecipeProvider>(context);

    final displayRecipes = recipeProvider.recipes;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await recipeProvider.refreshRecipes();
          },
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Row: Title & Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What are you\ncooking today?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded,
                            color: Color(0xFF1E1E24), size: 22),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Search Bar
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
                    decoration: const InputDecoration(
                      hintText: 'Search any recipes',
                      hintStyle: TextStyle(
                        color: Color(0xFF9EA6B5),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Color(0xFF9EA6B5), size: 22),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Green Promotional Banner Card
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF478677),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 20,
                        bottom: 20,
                        right: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Cook the best\nrecipes at home',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.explore);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Explore',
                                  style: TextStyle(
                                    color: Color(0xFF1E1E24),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=400&q=80',
                            width: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Categories Header & Pill Chips
                const Center(
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E24),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
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
                const SizedBox(height: 24),

                // 5. Quick & Easy Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick & Easy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.search);
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. Single-Row Horizontal Recipe Carousel
                if (recipeProvider.isLoading)
                  const LoadingWidget(message: 'Loading recipes...')
                else if (displayRecipes.isEmpty)
                  const EmptyState(
                    title: 'No Recipes Found',
                    description: 'No recipes match your criteria.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  SizedBox(
                    height: 175,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: displayRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = displayRecipes[index];
                        final isFav = recipeProvider.isFavorite(recipe.id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: RecipeCard(
                            recipe: recipe,
                            width: 150,
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
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addEditRecipe);
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: const Color(0xFF9EA6B5),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: 'Meal Plan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
