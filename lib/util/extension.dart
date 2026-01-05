import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesExtensions on SharedPreferences {
  Future<bool> setIsSignIn(bool value) {
    return setBool('isSignIn', value);
  }

  bool getIsSignIn() {
    return getBool('isSignIn') ?? false; // Default to false if not found
  }
}
