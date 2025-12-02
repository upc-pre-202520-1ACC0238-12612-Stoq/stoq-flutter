# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Stock Wise** is a Flutter inventory management application with multi-branch support, product scanning, and sales functionality. The app follows Clean Architecture with feature-based organization.

### Core Business Domain
- Multi-branch inventory management with real-time stock tracking
- Product catalog with categories, tags, and image recognition (Google ML Kit)
- Sales processing with stock validation
- Combo/kit product management
- Branch mapping with Google Maps integration
- User authentication with role-based access

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Build
flutter build apk          # Android
flutter build ios          # iOS

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Code analysis
flutter analyze

# Clean build cache (useful when switching branches or troubleshooting)
flutter clean && flutter pub get
```

## Architecture

### Feature-Based Structure
```
lib/
├── features/
│   ├── auth/           # Login, registration
│   ├── dashboard/      # Main tabs (Inicio, Inventario, Mapa)
│   ├── inventory/      # Multi-branch inventory, transfers
│   ├── products/       # Product catalog CRUD
│   ├── sales/          # Sales processing
│   ├── combos/         # Product kit management
│   ├── historial/      # Movement history and reports
│   └── profile/        # User settings
├── shared/
│   ├── constants/      # AppColors, AppSizes, AppStrings, ApiConstants
│   ├── services/       # StorageService (SharedPreferences wrapper)
│   └── widgets/        # CustomAppBar, CustomButton, LoadingOverlay
└── main.dart           # Entry point with SplashScreen
```

### Each Feature Contains
- `models/` - Data classes with `fromJson`/`toJson` methods
- `services/` - API calls with http package, mock data fallback
- `screens/` - StatefulWidget UI pages
- `widgets/` - Feature-specific components (optional)

### State Management
Traditional `StatefulWidget` with `setState()`. No Provider/Riverpod/BLoC. Business logic lives in service classes.

## API Integration

### Configuration
Base URL and endpoints are centralized in `lib/shared/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'http://34.39.181.148:8080/api/v1';
  static const String loginEndpoint = '/auth/signin';
  static const String productsEndpoint = '/products';
  // ... etc
}
```

### Service Pattern
All services follow this pattern with bearer token auth and mock data fallback:
```dart
class SomeService {
  Future<Data> fetchData() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.endpoint}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      // Parse or throw
    } catch (e) {
      return getMockData(); // Fallback for dev/offline
    }
  }
}
```

## UI System

### Design Tokens (in `shared/constants/app_constants.dart`)
- Primary: Orange `#EA580C`
- Background: Beige `#F5E6D3`
- Use `AppColors`, `AppSizes`, `AppStrings` constants throughout

### Navigation
Imperative navigation with `Navigator.push()`. Main entry point after login is `DashboardTabsScreen` with TabBar (Inicio, Inventario, Mapa tabs).

## Key Dependencies

From `pubspec.yaml`:
- `http` - API requests
- `shared_preferences` - Local token/user storage
- `google_maps_flutter` + `geolocator` - Branch mapping
- `image_picker` + `google_mlkit_image_labeling` - Product image recognition

## Code Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Use relative imports within a feature, absolute imports across features
- Spanish language UI strings (defined in `AppStrings`)
