class UserConfig {
  String username;
  String password;

  UserConfig({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      username: json['username'],
      password: json['password'],
    );
  }
}