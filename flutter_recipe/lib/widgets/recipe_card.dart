import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../app/theme.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final double? width;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.width = 155.0,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = recipe.name.isNotEmpty ? recipe.name : recipe.title;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Header Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    recipe.imageUrl,
                    height: 95,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 95,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.grey,
                        size: 26,
                      ),
                    ),
                  ),
                ),

                // Category Tag Top-Left
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(130),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Heart Icon Overlay Top-Right
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.red : const Color(0xFF1E1E24),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (Max 2 lines)
                  SizedBox(
                    height: 30,
                    child: Text(
                      titleText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating & Prep Time Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.secondaryColor, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        recipe.reviewCount > 0
                            ? '${recipe.rating.toStringAsFixed(1)} (${recipe.reviewCount})'
                            : 'New',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: Color(0xFF8A94A6)),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.preparationTime}m',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8A94A6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
