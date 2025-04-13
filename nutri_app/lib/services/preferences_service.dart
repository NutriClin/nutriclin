import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _kUserTypeKey = 'user_type';

  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserTypeKey, userType);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserTypeKey);
  }

  static Future<void> clearUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserTypeKey);
  }
}