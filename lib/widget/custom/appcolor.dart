import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF00FF00); // tumhara green color
  // static const Color secondary = Color(0xFF212121); // optional (was Colors.grey[900])
  static const Color secondary = Color(0xFF43A047); // green shade600
  
  static const Color accent = Color(0xFFFFA500); // optional


  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,                   
  );
}
