import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:image_picker/image_picker.dart';
import '../../app/theme.dart';
import '../../models/ingredient_model.dart';
import '../../models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditRecipeScreen extends StatefulWidget {
  const AddEditRecipeScreen({super.key});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _caloriesController;
  late TextEditingController _instructionsController;

  String _selectedCategory = 'Dinner';
  final List<String> _categories = [
    'Dinner',
    'Lunch',
    'Breakfast',
    'General',
    'Dessert',
    'Snack',
  ];

  final List<IngredientItemController> _ingredientControllers = [];

  RecipeModel? _existingRecipe;
  bool _isInit = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
    _prepTimeController = TextEditingController(text: '20');
    _cookTimeController = TextEditingController(text: '15');
    _servingsController = TextEditingController(text: '2');
    _caloriesController = TextEditingController(text: '150');
    _instructionsController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final recipe = ModalRoute.of(context)?.settings.arguments as RecipeModel?;
      if (recipe != null) {
        _existingRecipe = recipe;
        _titleController.text = recipe.name.isNotEmpty ? recipe.name : recipe.title;
        _descriptionController.text = recipe.description;
        _imageUrlController.text = recipe.imageUrl;
        _prepTimeController.text = recipe.preparationTime.toString();
        _cookTimeController.text = recipe.cookingTime.toString();
        _servingsController.text = recipe.servings.toString();
        _caloriesController.text = recipe.calories.toString();
        _instructionsController.text = recipe.instructions.join('\n');

        if (_categories.contains(recipe.category)) {
          _selectedCategory = recipe.category;
        } else {
          _selectedCategory = 'Dinner';
        }

        for (var ing in recipe.ingredients) {
          _ingredientControllers.add(IngredientItemController(
            name: ing.name,
            amount: ing.amount.toString(),
            unit: ing.unit,
            imageUrl: ing.imageUrl ?? '',
          ));
        }
      }

      if (_ingredientControllers.isEmpty) {
        _addIngredientRow();
      }

      _isInit = true;
    }
  }

  void _addIngredientRow() {
    setState(() {
      _ingredientControllers.add(IngredientItemController());
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one ingredient is required.')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _imageUrlController.text = dataUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image selected from gallery!')),
          );
        }
      }
    } catch (e) {
      debugPrint('[AddEditRecipeScreen] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageUrlController.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _instructionsController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUid = authProvider.currentUser?.id ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';

    if (currentUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create or edit recipes.')),
      );
      return;
    }

    final List<IngredientModel> ingredients = [];
    for (var controller in _ingredientControllers) {
      final name = controller.nameController.text.trim();
      final amount = double.tryParse(controller.amountController.text.trim()) ?? 1.0;
      final unit = controller.unitController.text.trim();
      final imgUrl = controller.imageUrlController.text.trim();

      if (name.isNotEmpty) {
        ingredients.add(IngredientModel(
          name: name,
          amount: amount,
          unit: unit.isNotEmpty ? unit : 'items',
          imageUrl: imgUrl.isNotEmpty ? imgUrl : null,
        ));
      }
    }

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one valid ingredient.')),
      );
      return;
    }

    final instructionsList = _instructionsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (instructionsList.isEmpty) {
      instructionsList.add('Mix ingredients and cook to desired taste.');
    }

    setState(() {
      _isSaving = true;
    });

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80';
    final prepTime = int.tryParse(_prepTimeController.text.trim()) ?? 20;
    final cookTime = int.tryParse(_cookTimeController.text.trim()) ?? 15;
    final servings = int.tryParse(_servingsController.text.trim()) ?? 2;
    final calories = int.tryParse(_caloriesController.text.trim()) ?? 150;

    bool success = false;

    if (_existingRecipe == null) {
      final newRecipe = RecipeModel(
        id: '',
        name: title,
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: _selectedCategory,
        calories: calories,
        preparationTime: prepTime,
        cookingTime: cookTime,
        servings: servings,
        ingredients: ingredients,
        instructions: instructionsList,
        createdBy: currentUid,
        createdAt: DateTime.now(),
      );

      success = await recipeProvider.addRecipe(newRecipe);
    } else {
      final updatedRecipe = _existingRecipe!.copyWith(
        name: title,
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: _selectedCategory,
        calories: calories,
        preparationTime: prepTime,
        cookingTime: cookTime,
        servings: servings,
        ingredients: ingredients,
        instructions: instructionsList,
        updatedAt: DateTime.now(),
      );

      success = await recipeProvider.updateRecipe(updatedRecipe);
    }

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingRecipe == null
                ? 'Recipe created successfully!'
                : 'Recipe updated successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recipeProvider.errorMessage ?? 'Operation failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E24),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingRecipe != null;
    final currentImageSrc = _imageUrlController.text.trim();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Recipe' : 'Add New Recipe',
          style: const TextStyle(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Section 1: Basic Information
                _buildSectionCard(
                  title: 'Basic Information',
                  icon: Icons.restaurant_menu_rounded,
                  iconColor: AppTheme.primaryColor,
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Recipe Title *',
                      hintText: 'Enter recipe title...',
                      prefixIcon: Icons.title_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Recipe title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E1E24),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Description *',
                      hintText: 'Briefly describe your recipe...',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                // Section 2: Recipe Image & Preview
                _buildSectionCard(
                  title: 'Recipe Image',
                  icon: Icons.camera_alt_rounded,
                  iconColor: Colors.orangeAccent,
                  children: [
                    if (currentImageSrc.isEmpty)
                      GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor.withAlpha(100),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded,
                                  size: 44, color: AppTheme.primaryColor),
                              SizedBox(height: 8),
                              Text(
                                'Add Recipe Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1E1E24),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap to choose from gallery',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                          ),
                          child: currentImageSrc.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(currentImageSrc.split(',').last),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) =>
                                      const Center(child: Icon(Icons.broken_image, size: 40)),
                                )
                              : Image.network(
                                  currentImageSrc,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) =>
                                      const Center(child: Icon(Icons.broken_image, size: 40)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: const Icon(Icons.photo_library_rounded, size: 16),
                              label: const Text('Change Image'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: _removeImage,
                            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                            label: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _imageUrlController,
                      labelText: 'Image URL (Optional Fallback)',
                      hintText: 'https://example.com/image.jpg',
                      prefixIcon: Icons.link_rounded,
                    ),
                  ],
                ),

                // Section 3: Cooking Information
                _buildSectionCard(
                  title: 'Cooking Information',
                  icon: Icons.timer_outlined,
                  iconColor: Colors.blueAccent,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _prepTimeController,
                            labelText: 'Prep (Min) *',
                            hintText: '20',
                            prefixIcon: Icons.access_time_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || int.tryParse(val.trim()) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: _cookTimeController,
                            labelText: 'Cook (Min) *',
                            hintText: '15',
                            prefixIcon: Icons.local_fire_department_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || int.tryParse(val.trim()) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _servingsController,
                            labelText: 'Servings *',
                            hintText: '2',
                            prefixIcon: Icons.people_outline_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || (int.tryParse(val.trim()) ?? 0) <= 0) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: _caloriesController,
                            labelText: 'Calories',
                            hintText: '150',
                            prefixIcon: Icons.flash_on_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Section 4: Dynamic Ingredients
                _buildSectionCard(
                  title: 'Ingredients',
                  icon: Icons.format_list_bulleted_rounded,
                  iconColor: Colors.green,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ingredientControllers.length,
                      itemBuilder: (context, index) {
                        final item = _ingredientControllers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustomTextField(
                                  controller: item.nameController,
                                  hintText: 'Ingredient',
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Req';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: item.amountController,
                                  hintText: 'Amount',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (val) {
                                    if (val == null || double.tryParse(val.trim()) == null) {
                                      return 'Req';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: item.unitController,
                                  hintText: 'Unit',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _removeIngredientRow(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: _addIngredientRow,
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('+ Add Ingredient'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),

                // Section 5: Instructions
                _buildSectionCard(
                  title: 'Instructions',
                  icon: Icons.menu_book_rounded,
                  iconColor: Colors.purpleAccent,
                  children: [
                    CustomTextField(
                      controller: _instructionsController,
                      labelText: 'Step-by-step Instructions (One per line) *',
                      hintText: 'Step 1: Prep ingredients\nStep 2: Cook for 15 mins',
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Instructions are required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                // Submit Button
                CustomButton(
                  text: isEditing ? '✓ Update Recipe' : '✓ Save Recipe',
                  isLoading: _isSaving,
                  onPressed: _submitForm,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IngredientItemController {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController unitController;
  final TextEditingController imageUrlController;

  IngredientItemController({
    String name = '',
    String amount = '1',
    String unit = 'pcs',
    String imageUrl = '',
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount),
        unitController = TextEditingController(text: unit),
        imageUrlController = TextEditingController(text: imageUrl);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
    imageUrlController.dispose();
  }
}
