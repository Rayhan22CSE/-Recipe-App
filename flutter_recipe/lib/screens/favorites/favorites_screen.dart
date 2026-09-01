import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: favRecipes.isEmpty
          ? const EmptyState(
              title: 'No Favorites Yet',
              description:
                  'Tap the heart icon on any recipe card to save it to your personal favorites list.',
              icon: Icons.favorite_border_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
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
