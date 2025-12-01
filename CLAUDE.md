# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🏗️ Project Overview

**Stock Wise** is a Flutter-based inventory management application with multi-branch support, product scanning, and sales functionality. The app follows Clean Architecture principles with feature-based organization.

### Core Business Domain
- Multi-branch inventory management with real-time stock tracking
- Product catalog with categories, tags, and image recognition
- Sales processing with stock validation
- Branch mapping and geographic distribution
- User authentication with role-based access

## 📁 Architecture

### Clean Architecture - Feature-Based Structure
```
lib/
├── features/                    # Business features
│   ├── auth/                   # Authentication (login, user management)
│   ├── dashboard/              # Main dashboard with statistics
│   ├── inventory/              # Inventory management (multi-branch)
│   ├── products/               # Product catalog management
│   └── profile/                # User profile and settings
├── shared/                     # Cross-cutting concerns
│   ├── constants/              # App colors, sizes, strings
│   ├── services/               # Storage, shared utilities
│   └── widgets/                # Reusable UI components
└── main.dart                   # App entry point
```

### Feature Organization Pattern
Each feature follows this structure:
- `models/` - Data models with JSON serialization
- `services/` - API integration and business logic
- `screens/` - UI screens (StatefulWidget pattern)
- `widgets/` - Feature-specific reusable components

### State Management Approach
- **Traditional StatefulWidget** with `setState()` calls
- **Service Layer Pattern** for business logic separation
- **SharedPreferences** for local data persistence
- No global state management libraries (Provider, Riverpod, BLoC)

## 🛠️ Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for different platforms
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows

# Run tests
flutter test

# Code analysis
flutter analyze
```

### Asset Management
```bash
# Update assets after adding new images
flutter pub get

# Clean build cache
flutter clean
```

## 🌐 API Integration

### Backend Configuration
- **Base URL**: `http://34.39.181.148:8080/api/v1` (hardcoded in services)
- **Authentication**: Bearer token with SharedPreferences storage
- **Error Handling**: Fallback to mock data when API fails

### Key Service Endpoints
- **Auth**: `/authentication/sign-in`
- **Inventory**: `/inventory`, `/inventory/by-product`
- **Products**: `/products`, `/tags`
- **Sales**: `/sales`, `/sales/check-stock/:productId`

### Service Pattern
All services follow this pattern:
```dart
class SomeService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';

  Future<ResponseType> apiCall() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return parseResponse(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return getMockData();
    }
  }
}
```

## 🎨 UI Architecture

### Design System
- **Primary Color**: Orange (#EA580C)
- **Background**: Beige (#F5E6D3)
- **Material Design 3** implementation
- **Custom Widgets**: CustomAppBar, CustomButton, CustomCard, LoadingOverlay

### Navigation Pattern
- **Imperative Navigation** with `Navigator.push()`
- **TabBar** for multi-section screens (Dashboard)
- **No routing library** - direct screen navigation

### Screen Structure
- **SplashScreen**: Authentication check and navigation
- **DashboardTabsScreen**: Main app interface with 3 tabs (Inicio, Inventario, Mapa)
- **Feature Screens**: Individual screens for each business capability

## 📊 Business Models

### Multi-Branch Inventory
```dart
class Product {
  final Map<String, int> stockByBranch; // {'branch_id': quantity}
  final String name;
  final String provider;

  int get totalStock => stockByBranch.values.fold(0, (sum, q) => sum + q);
  int stockInBranch(String branchId) => stockByBranch[branchId] ?? 0;
}
```

### Branch Management
```dart
class Branch {
  final String id;
  final String name;
  final String type; // 'central', 'sucursal', 'almacen'
  final double latitude;
  final double longitude;
  final int stockTotal;
  final int alertLevel; // 0: green, 1: orange, 2: red
}
```

### Sales Integration
- **Single product per sale** (current API design)
- **Real-time stock validation** before sales
- **Customer tracking** with names and notes

## 🔐 Security Considerations

### Current Implementation
- Token-based authentication stored in SharedPreferences
- No refresh token mechanism
- Hardcoded API URL (security risk)
- No certificate pinning

### Development Notes
- API calls include 10-15 second timeouts
- Mock data fallback for development/offline mode
- No input validation beyond basic Flutter form validation

## 🚧 Development Priorities

### Known Issues
- Hardcoded API URL needs environment configuration
- Missing refresh token for session management
- No caching layer for API responses
- Performance issues with setState() on large lists

### Planned Features
- **Sales Module**: Replace "Devoluciones" button with full sales functionality
- **State Management**: Migration to BLoC or Riverpod
- **Testing**: Unit and widget test implementation
- **Offline Mode**: Local database for offline operation

## 📝 Key Conventions

### Code Style
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `PascalCase` in dedicated classes (AppColors, AppSizes, AppStrings)

### Feature Development
1. Create feature folder structure
2. Define models with JSON serialization
3. Implement service layer with API integration
4. Build screens with StatefulWidget pattern
5. Add reusable widgets to shared folder
6. Update constants and navigation

### Import Organization
```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Relative imports within feature
import '../models/some_model.dart';
import '../services/some_service.dart';

// Absolute imports for other features
import '../../other_feature/screens/other_screen.dart';

// Shared imports
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
```