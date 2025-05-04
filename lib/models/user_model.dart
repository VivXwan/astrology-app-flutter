import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  
  User({
    required this.id,
    required this.name,
    required this.email,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String tokenType;
  
  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.tokenType,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? {}),
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
} 