import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../models/recipe_model.dart';
import '../../providers/recipe_provider.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)?.settings.arguments as RecipeModel?;
    final recipeProvider = Provider.of<RecipeProvider>(context);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe Details')),
        body: const Center(child: Text('No recipe selected')),
      );
    }

    final recipeName = recipe.name.isNotEmpty ? recipe.name : recipe.title;
    final currentServings =
        recipeProvider.getServings(recipe.id, recipe.servings);
    final isFav = recipeProvider.isFavorite(recipe.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Top Image with Back & Notification Overlay Buttons
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: Color(0xFF1E1E24), size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded,
                            color: Color(0xFF1E1E24), size: 22),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 64, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),

              // Main Details Content Card Overlay
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 12.0, bottom: 100.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Drag Handle Bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recipe Title
                      Text(
                        recipeName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Stats Row (⚡ 120 Cal · 🕒 15 Min)
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded,
                              size: 16, color: Color(0xFF8A94A6)),
                          const SizedBox(width: 2),
                          Text(
                            '${recipe.calories} Cal',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A94A6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '·',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A94A6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.access_time_rounded,
                              size: 16, color: Color(0xFF8A94A6)),
                          const SizedBox(width: 2),
                          Text(
                            '${recipe.preparationTime} Min',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A94A6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Rating Row (⭐ 5.0/5 (23 Reviews))
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.secondaryColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            recipe.rating > 0
                                ? '${recipe.rating.toStringAsFixed(1)}/5'
                                : 'New',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E24),
                            ),
                          ),
                          if (recipe.reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${recipe.reviewCount} Reviews)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8A94A6),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ingredients Header & Servings Adjuster
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E24),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'How many servings?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),

                          // Servings Counter (-  1  +)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    recipeProvider.decrementServings(
                                        recipe.id, recipe.servings);
                                  },
                                  child: const Icon(Icons.remove_rounded,
                                      size: 20, color: Color(0xFF1E1E24)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: Text(
                                    '$currentServings',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E24),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    recipeProvider.incrementServings(
                                        recipe.id, recipe.servings);
                                  },
                                  child: const Icon(Icons.add_rounded,
                                      size: 20, color: Color(0xFF1E1E24)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Ingredient Items List with Thumbnails
                      if (recipe.ingredients.isEmpty)
                        const Text('No ingredients listed.',
                            style: TextStyle(color: Color(0xFF8A94A6)))
                      else
                        ...recipe.ingredients.map(
                          (ing) {
                            final formattedAmt = ing.formattedAmount(
                                currentServings, recipe.servings);
                            final displayAmount = formattedAmt.isNotEmpty
                                ? '$formattedAmt${ing.unit}'
                                : '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: Row(
                                children: [
                                  // Ingredient Thumbnail Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: ing.imageUrl != null &&
                                            ing.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            ing.imageUrl!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _buildDefaultThumbnail(),
                                          )
                                        : _buildDefaultThumbnail(),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      ing.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF8A94A6),
                                      ),
                                    ),
                                  ),
                                  if (displayAmount.isNotEmpty)
                                    Text(
                                      displayAmount,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8A94A6),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fixed Bottom Bar with "Start Cooking" Button and Heart Icon
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Cooking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    recipeProvider.toggleFavorite(recipe.id);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red : const Color(0xFF1E1E24),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.restaurant_rounded, size: 22, color: Colors.grey),
    );
  }
}
