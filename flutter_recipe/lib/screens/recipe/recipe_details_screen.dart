import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/recipe_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/custom_button.dart';

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 5.0;
  bool _isSubmittingReview = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(
      BuildContext context, RecipeModel recipe, String currentUid, String userName) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review comment.')),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final review = ReviewModel(
      id: '',
      recipeId: recipe.id,
      userId: currentUid,
      userName: userName.isNotEmpty ? userName : 'Food Enthusiast',
      rating: _selectedRating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final success = await recipeProvider.submitReview(review);

    setState(() {
      _isSubmittingReview = false;
    });

    if (mounted) {
      if (success) {
        _commentController.clear();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your review has been submitted.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(recipeProvider.errorMessage ?? 'Failed to submit review.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)?.settings.arguments as RecipeModel?;
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe Details')),
        body: const Center(child: Text('No recipe selected')),
      );
    }

    final currentUid = authProvider.currentUser?.id ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    final currentUserName = authProvider.currentUser?.name ?? 'User';
    final isOwner = currentUid.isNotEmpty && recipe.createdBy == currentUid;

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
              // Hero Top Image with Back & Action Overlay Buttons
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
                  if (isOwner) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Color(0xFF1E1E24), size: 20),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.addEditRecipe,
                              arguments: recipe,
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent, size: 20),
                          onPressed: () =>
                              _confirmDelete(context, recipe, recipeProvider),
                        ),
                      ),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: recipe.imageUrl.startsWith('data:image')
                      ? Image.network(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.restaurant,
                                  size: 64, color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : Image.network(
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

                      // Recipe Title & Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipeName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E24),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recipe.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      if (recipe.description.isNotEmpty) ...[
                        Text(
                          recipe.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A94A6),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

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

                      // Real-time Dynamic Rating Summary Row
                      StreamBuilder<List<ReviewModel>>(
                        stream: recipeProvider.watchReviews(recipe.id),
                        builder: (context, snapshot) {
                          final reviews = snapshot.data ?? [];
                          final count = reviews.length;
                          double avg = 0.0;
                          if (count > 0) {
                            final total = reviews.fold<double>(
                                0.0, (sum, r) => sum + r.rating);
                            avg = total / count;
                          }

                          final reviewText = count == 0
                              ? 'No reviews yet'
                              : count == 1
                                  ? '1 review'
                                  : '$count reviews';

                          return Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.secondaryColor, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                count > 0
                                    ? '${avg.toStringAsFixed(1)} / 5.0'
                                    : 'No ratings yet',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E24),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '($reviewText)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A94A6),
                                ),
                              ),
                            ],
                          );
                        },
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

                      // Ingredient Items List
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

                      const SizedBox(height: 24),

                      // Cooking Instructions Section
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (recipe.instructions.isEmpty)
                        const Text('No instructions provided.',
                            style: TextStyle(color: Color(0xFF8A94A6)))
                      else
                        ...recipe.instructions.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final step = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      AppTheme.primaryColor.withAlpha(20),
                                  child: Text(
                                    '$idx',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Color(0xFF1E1E24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 28),

                      // Real-time Reviews Section
                      const Text(
                        'Reviews & Ratings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stream Builder for Real Reviews
                      StreamBuilder<List<ReviewModel>>(
                        stream: recipeProvider.watchReviews(recipe.id),
                        builder: (context, snapshot) {
                          final reviews = snapshot.data ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reviews.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    'No reviews yet. Be the first to review this recipe!',
                                    style: TextStyle(color: Color(0xFF8A94A6)),
                                  ),
                                )
                              else
                                ...reviews.map((rev) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(5),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: AppTheme.primaryColor.withAlpha(30),
                                              child: Text(
                                                rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'U',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryColor),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                rev.userName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF1E1E24),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(5, (starIdx) {
                                                return Icon(
                                                  starIdx < rev.rating
                                                      ? Icons.star_rounded
                                                      : Icons.star_border_rounded,
                                                  color: AppTheme.secondaryColor,
                                                  size: 16,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          rev.comment,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF4A4A4A),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                              const SizedBox(height: 20),

                              // Leave / Edit Review Input Form
                              if (currentUid.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lock_outline_rounded, color: Colors.amber),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Log in to leave a review for this recipe.',
                                          style: TextStyle(fontSize: 13, color: Colors.black87),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                                        child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Leave a Review',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E1E24),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Interactive Star Selector
                                      Row(
                                        children: [
                                          const Text('Your Rating: ',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                          ...List.generate(5, (index) {
                                            final starValue = index + 1.0;
                                            return IconButton(
                                              icon: Icon(
                                                starValue <= _selectedRating
                                                    ? Icons.star_rounded
                                                    : Icons.star_border_rounded,
                                                color: AppTheme.secondaryColor,
                                                size: 26,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedRating = starValue;
                                                });
                                              },
                                            );
                                          }),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Comment Field
                                      TextField(
                                        controller: _commentController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Share your thoughts on this recipe...',
                                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      CustomButton(
                                        text: 'Submit Review',
                                        isLoading: _isSubmittingReview,
                                        onPressed: () => _submitReview(
                                            context, recipe, currentUid, currentUserName),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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

  void _confirmDelete(
      BuildContext context, RecipeModel recipe, RecipeProvider recipeProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text(
            'Are you sure you want to delete this recipe? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await recipeProvider.deleteRecipe(recipe.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recipe deleted successfully.'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(recipeProvider.errorMessage ??
                          'Failed to delete recipe.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
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
