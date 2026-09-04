import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/recipe_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final favRecipes = recipeProvider.recipes
        .where((r) => recipeProvider.isFavorite(r.id))
        .toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1100
        ? 4
        : (screenWidth >= 650 ? 3 : 2);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: favRecipes.isEmpty
          ? const EmptyState(
              title: 'No Favorites Yet',
              description:
                  'Tap the heart icon on any recipe card to save it to your personal favorites list.',
              icon: Icons.favorite_border_rounded,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.08,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favRecipes[index];
                return RecipeCard(
                  recipe: recipe,
                  isFavorite: true,
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
    );
  }
}
