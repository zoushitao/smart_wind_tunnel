import 'dart:convert';
import 'dart:io';

import './user_config_model.dart';

import 'package:flutter/material.dart';

class UserConfigProvider with ChangeNotifier {
  late UserConfig _userConfig;

  UserConfig get userConfig => _userConfig;

  Future<void> loadUserConfig() async {
    try {
      File file = File('user_config.json');
      if (file.existsSync()) {
        String jsonString = await file.readAsString();
        Map<String, dynamic> json = jsonDecode(jsonString);
        _userConfig = UserConfig.fromJson(json);
      }
    } catch (e) {
      print('Failed to load user config: $e');
    }
  }

  Future<void> saveUserConfig() async {
    try {
      File file = File('user_config.json');
      String jsonString = jsonEncode(_userConfig.toJson());
      await file.writeAsString(jsonString);
      notifyListeners();
    } catch (e) {
      print('Failed to save user config: $e');
    }
  }

  void updateUserConfig({required String username, required String password}) {
    _userConfig.username = username ?? _userConfig.username;
    _userConfig.password = password ?? _userConfig.password;
    saveUserConfig();
  }
}
