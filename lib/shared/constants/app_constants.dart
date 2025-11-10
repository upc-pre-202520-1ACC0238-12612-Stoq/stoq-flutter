import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFEA580C); // Naranja
  static const Color secondary = Color(0xFFF5E6D3); // Beige de fondo
  static const Color accent = Color(0xFFDC2626); // Rojo
  
  // Colores de estado
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;
  
  // Colores de superficie
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF5E6D3);
  static const Color cardBackground = Colors.white;
  
  // Colores de texto
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textLight = Colors.white;
}

class AppSizes {
  // Padding y margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;
  
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;
  
  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Button heights
  static const double buttonHeight = 48.0;
}

class AppStrings {
  // App
  static const String appName = 'Stock Wise';
  
  // Auth
  static const String login = 'Inicio de sesión';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String rememberMe = 'Recuérdame';
  static const String signIn = 'Iniciar sesión';
  static const String signInWithGoogle = 'Iniciar con google';
  static const String noAccount = '¿No tienes una cuenta?';
  static const String logout = 'Cerrar sesión';
  
  // Dashboard
  static const String totalProducts = 'Total Productos';
  static const String providerDate = 'Fecha Provedor';
  static const String movementHistory = 'Historial Movimientos';
  static const String inventory = 'Inventario';
  static const String addProducts = 'Agregar Productos';
  static const String kitsProducts = 'Kits Productos';
  static const String returnProducts = 'Devolución Productos';
  static const String stock = 'Stock';
  
  // Messages
  static const String comingSoon = 'Próximamente';
  static const String connectionError = 'Error de conexión';
  static const String loginError = 'Error al iniciar sesión';
}