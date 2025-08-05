import 'package:flutter/material.dart';
import 'package:smart_waste_management/screens/auth_screen.dart';

class AuthService {
  static Future<void> logout(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
