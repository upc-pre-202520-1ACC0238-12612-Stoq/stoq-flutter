import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFEA580C); // Naranja
  static const Color secondary = Color(0xFFF5E6D3); // Beige de fondo
  static const Color yellowHighlight = Color(0xFFFFEDB5);  // Amarillo destacado
  static const Color beigeSecondary = Color(0xFFD9D593);   // Beige secundario
  static const Color black = Color(0xFF000000);            // Negro
  static const Color white = Color(0xFFFFFFFF);            // Blanco
  static const Color darkGray = Color(0xFF302325);         // Gris oscuro
  static const Color redAccent = Color(0xFFBC162A);        // Rojo acento
  
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

   // Colores con opacidad (para evitar usar withOpacity)
  static const Color textLight90 = Color(0xE6FFFFFF); // 90% opacity
  static const Color primary10 = Color(0x1AEA580C); // 10% opacity
  static const Color primary30 = Color(0x4DEA580C); // 30% opacity
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
  static const String salesProducts = 'Realizar Venta';
  static const String stock = 'Stock';
  
  // Settings
  static const String settings = 'Ajustes';
  static const String notificationSystem = 'Sistema de Notificaciones';
  static const String lowStockAlerts = 'Alertas de stock bajo';
  static const String expiryReminders = 'Recordatorios de productos próximos a vencer';
  static const String pushNotifications = 'Notificaciones push';
  static const String appPreferences = 'Preferencias de la App';
  static const String darkMode = 'Modo oscuro';
  static const String autoBackup = 'Copia de seguridad automática';
  static const String inventoryManagement = 'Gestión de Inventarios';
  static const String configureInventory = 'Configurar Inventario';
  static const String saveSettings = 'Guardar Configuración';
  
  // Messages
  static const String comingSoon = 'Próximamente';
  static const String connectionError = 'Error de conexión';
  static const String loginError = 'Error al iniciar sesión';
}