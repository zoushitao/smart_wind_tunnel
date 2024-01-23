import 'dart:convert';
import 'dart:io';

import 'user_config_model.dart';

import 'package:flutter/material.dart';

class UserConfigProvider with ChangeNotifier {
  late UserConfig _userConfig;

  //Basic Properties
  static const String _jsonFileName = "user_config.json";

  UserConfig get userConfig => _userConfig;

  Future<void> loadUserConfig() async {
    try {
      File file = File(_jsonFileName);
      if (file.existsSync()) {
        String jsonString = await file.readAsString();
        Map<String, dynamic> json = jsonDecode(jsonString);
        _userConfig = UserConfig.fromJson(json);
      } else {
        _initJSONFile();
      }
    } catch (e) {
      //print('Failed to load user config: $e');
    }
  }

  Future<void> saveUserConfig() async {
    try {
      File file = File(_jsonFileName);
      if (file.existsSync()) {
        String jsonString = jsonEncode(_userConfig.toJson());
        await file.writeAsString(jsonString);
        notifyListeners();
      } else {
        _initJSONFile();
      }
    } catch (e) {
      //print('Failed to save user config: $e');
    }
  }

  void updateUserConfig({required String username, required String password}) {
    _userConfig.username = username ?? _userConfig.username;
    _userConfig.password = password ?? _userConfig.password;
    saveUserConfig();
  }

  void _initJSONFile() {
    final file = File('user_config.json');

    if (file.existsSync()) {
      // If the file exists, read its content
      final jsonString = file.readAsStringSync();
      // ignore: unused_local_variable
      final jsonData = json.decode(jsonString);
      // Use the parsed JSON data
      //print(jsonData['name']);
      //print(jsonData['age']);
    } else {
      // If the file doesn't exist, create it and write initial JSON data
      final jsonData = {
        'name': 'John Doe',
        'age': 30,
      };
      final jsonString = json.encode(jsonData);
      file.writeAsStringSync(jsonString);
      //print('JSON file created and initial data written');
    }
  }

  static const String _defualtConfig = """
  'name': 'John Doe',
        'age': 30,
  """;


}
