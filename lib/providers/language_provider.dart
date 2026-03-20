import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage;
  
  // Available languages
  static const List<String> languages = ['English', 'Ilocano', 'Filipino'];
  static const List<String> languageCodes = ['en', 'il', 'tl'];
  
  LanguageProvider(this._currentLanguage) {
    if (_currentLanguage.isEmpty) {
      _currentLanguage = 'en'; // Default to English
    }
  }
  
  String get currentLanguage => _currentLanguage.isNotEmpty ? _currentLanguage : 'en';
  String get currentLanguageCode => currentLanguage;
  
  Future<void> setLanguage(String languageCode) async {
    if (languageCode.isNotEmpty) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    }
  }

  // Get translated text
  String translate(String en, String il, String tl) {
    switch (_currentLanguage) {
      case 'il':
        return il.isNotEmpty ? il : en;
      case 'tl':
        return tl.isNotEmpty ? tl : en;
      default:
        return en.isNotEmpty ? en : '';
    }
  }

  // Get translated list
  List<String> translateList(List<String> en, List<String> il, List<String> tl) {
    switch (_currentLanguage) {
      case 'il':
        return il;
      case 'tl':
        return tl;
      default:
        return en;
    }
  }
}