import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/recipe/recipe_details_screen.dart';
import '../screens/recipe/add_edit_recipe_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String explore = '/explore';
  static const String recipeDetails = '/recipe-details';
  static const String addEditRecipe = '/add-edit-recipe';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      search: (context) => const SearchScreen(),
      explore: (context) => const ExploreScreen(),
      recipeDetails: (context) => const RecipeDetailsScreen(),
      addEditRecipe: (context) => const AddEditRecipeScreen(),
      favorites: (context) => const FavoritesScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }
}
