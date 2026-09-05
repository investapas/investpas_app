import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/product.dart';
import 'navigationService.dart';


/// app storage
class AppGetXStorage {
  const AppGetXStorage._();

  /// instance
  static const AppGetXStorage instance = AppGetXStorage._();

  /// themeMode
  static const themeMode = 'theme_mode';
/// user profile
  static const userData = 'user_data';

   /// wish list
  static const wishList='wish_list';
  

 
  
/// Removes the user data from the storage.
///
/// This function removes the user data from the storage, effectively logging the user out.
///
/// No parameters are required.
///
/// No return value.
   void logout() {
    final box = GetStorage();
    box.remove(userData);
    box.remove(wishList);
  }
/// Adds a product to the wishlist stored in the GetStorage, updating the wishlist in the storage.
 void addToWishlist(ProductModel product) {
    final box = GetStorage();
    final List<dynamic> currentWishlist = box.read(wishList) ?? [];
    final List<ProductModel> wishlist = currentWishlist.map((item) => ProductModel.fromJson(item)).toList();
    wishlist.add(product);

    box.write(wishList, wishlist.map((product) => product.toJson).toList());
  }

  /// Removes the provided product from the wishlist stored in the GetStorage.
   void removeFromWishlist(ProductModel product) {
    final box = GetStorage();
    final List<dynamic> currentWishlist = box.read(wishList) ?? [];
    final List<ProductModel> wishlist = currentWishlist.map((item) => ProductModel.fromJson(item)).toList();
    wishlist.removeWhere((item) => item.id == product.id);

    box.write(wishList, wishlist.map((product) => product.toJson).toList());
  }

  /// Retrieves the wishlist from the GetStorage instance.
  ///
  /// This function retrieves the wishlist stored in the GetStorage instance and
  /// returns it as a list of `ProductModel` objects. If the wishlist is not
  /// available in the storage, an empty list is returned.
  ///
  /// Returns:
  ///   - A list of `ProductModel` objects representing the wishlist.
   List<ProductModel> getWishlist() {
    final box = GetStorage();
    final List<dynamic> currentWishlist = box.read(wishList) ?? [];
    return currentWishlist.map((item) => ProductModel.fromJson(item)).toList();
  }

  /// set theme mode
 static void setThemeMode(bool isDark) {
    final box = GetStorage();
    box.write(themeMode, isDark);
  }
  /// get theme mode
 static bool getIsDarkTheme() {
    final box = GetStorage();
    final stored = box.read(themeMode);
    if (stored != null) return stored;
    
    try {
      final context = NavigatorService.navigatorKey.currentState?.context;
      if (context != null) {
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      }
    } catch (e) {
      // Ignore errors during initialization
    }
    
    return false;
  }


}
