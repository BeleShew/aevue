import 'dart:convert';

import 'package:aevue/model/products_response.dart';
import 'package:aevue/util/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataBase {
  static final LocalDataBase _instance = LocalDataBase._internal();
  static SharedPreferences? _prefs;

  factory LocalDataBase() {
    return _instance;
  }

  LocalDataBase._internal();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, Map<String, dynamic> map) async {
    await _ensureInitialized();
    final String mapString = jsonEncode(map);
    _prefs?.setString(key, mapString);
  }

  static Future<void> saveStringList(String key, Map<String, dynamic> values) async {
    await _ensureInitialized();
    final List<String>? existingList = _prefs?.getStringList(key);
    final Set<String> existingSet = existingList != null ? existingList.toSet() : {};
    final String encodedList = jsonEncode(values);
    existingSet.add(encodedList);
    // Save the updated set back to SharedPreferences
    await _prefs?.setStringList(key, existingSet.toList());
  }

  static Future<void> saveStringLists(String key, List<Map<String, dynamic>> values) async {
    await _ensureInitialized();
    // Convert each map to JSON string
    List<String> jsonList = values.map((map) => jsonEncode(map)).toList();
    // Remove duplicates
    Set<String> uniqueJsonList = jsonList.toSet();
    // Save the updated set back to SharedPreferences
    await _prefs?.setStringList(key, uniqueJsonList.toList());
  }

  static Future<Map<String, dynamic>?> getString(String key) async {
    await _ensureInitialized();
    final String? mapString = _prefs?.getString(key);
    if (mapString != null) {
      return Map<String, dynamic>.from(jsonDecode(mapString));
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getStringList(String key) async {
    await _ensureInitialized();
    final List<String>? stringList = _prefs?.getStringList(key);
    if (stringList != null&&stringList.isNotEmpty) {
      List<Map<String, dynamic>> mappedList = stringList
          .map((stringItem) => Map<String, dynamic>.from(jsonDecode(stringItem)))
          .toList();
      return mappedList;
    }
    return [];
  }

  static Future<void> deleteAllValues(String key) async {
    await _ensureInitialized();
    await _prefs?.remove(key);
  }


  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}