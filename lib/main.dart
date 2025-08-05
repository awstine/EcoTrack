import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const SmartWasteApp());
}

class SmartWasteApp extends StatelessWidget {
  const SmartWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Waste Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'OpenSans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
