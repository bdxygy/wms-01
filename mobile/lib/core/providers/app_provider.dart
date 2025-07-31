import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms_mobile/core/utils/number_utils.dart';
import '../models/currency.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('id', 'ID');
  Currency _currency = SupportedCurrencies.usd;
  bool _isInitialized = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Currency get currency => _currency;
  bool get isInitialized => _isInitialized;

  // Theme management
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode(mode);
    notifyListeners();
  }

  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  // Locale management
  void setLocale(Locale locale) {
    _locale = locale;
    _saveLocale(locale);
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('id', 'ID'));
    } else {
      setLocale(const Locale('en', 'US'));
    }
  }

  // Currency management
  void setCurrency(Currency currency) {
    _currency = currency;
    _saveCurrency(currency);
    notifyListeners();
  }

  String formatCurrency(double amount) {
    return '${_currency.symbol}${NumberUtils.formatWithDots(amount.toInt())}';
  }

  String formatCurrencyWithCode(double amount) {
    return '${_currency.symbol}${NumberUtils.formatWithDots(amount.toInt())} ${_currency.code}';
  }

  // Initialize app settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeIndex = prefs.getInt('theme_mode') ?? 1; // Default to light mode (index 1)
      _themeMode = ThemeMode.values[themeIndex];

      // Load locale
      final languageCode = prefs.getString('language_code') ?? 'id';
      final countryCode = prefs.getString('country_code') ?? 'ID';
      _locale = Locale(languageCode, countryCode);

      // Load currency
      final currencyCode = prefs.getString('currency_code') ?? 'USD';
      _currency = SupportedCurrencies.fromCode(currencyCode);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Handle error - use defaults
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Private methods for persistence
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveCurrency(Currency currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency_code', currency.code);
    } catch (e) {
      // Handle error silently
    }
  }

  // Reset app settings
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('theme_mode');
      await prefs.remove('language_code');
      await prefs.remove('country_code');
      await prefs.remove('currency_code');

      _themeMode = ThemeMode.light;
      _locale = const Locale('id', 'ID');
      _currency = SupportedCurrencies.usd;
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
}
