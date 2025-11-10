# Stock Wise - Arquitectura del Proyecto

## 📁 Estructura de Carpetas por Features

Este proyecto sigue una arquitectura **Clean Architecture** organizando el código por características (features) en lugar de por tipos de archivos.

```
lib/
├── core/                           # Configuraciones centrales
├── features/                       # Características de la aplicación
│   ├── auth/                      # Feature de autenticación
│   │   ├── models/                # Modelos de datos
│   │   │   ├── login_request.dart
│   │   │   └── login_response.dart
│   │   ├── services/              # Servicios y repositorios
│   │   │   ├── auth_service.dart
│   │   │   └── mock_auth_service.dart
│   │   └── screens/               # Pantallas del feature
│   │       └── login_screen.dart
│   └── dashboard/                 # Feature del dashboard
│       ├── models/                # Modelos del dashboard
│       │   └── product.dart
│       └── screens/               # Pantallas del dashboard
│           └── dashboard_screen.dart
├── shared/                        # Código compartido
│   ├── constants/                 # Constantes de la aplicación
│   │   └── app_constants.dart
│   └── widgets/                   # Widgets reutilizables
│       └── custom_widgets.dart
└── main.dart                      # Punto de entrada
```

## 🏗️ Ventajas de esta Arquitectura

### ✅ **Escalabilidad**
- Cada feature es independiente
- Fácil agregar nuevas características
- Código modular y mantenible

### ✅ **Organización Clara**
- Estructura intuitiva por funcionalidad
- Fácil ubicar archivos relacionados
- Separación de responsabilidades

### ✅ **Reutilización**
- Widgets y constantes compartidas
- Servicios reutilizables entre features
- Modelos consistentes

### ✅ **Testing**
- Fácil hacer tests unitarios por feature
- Mocking simplificado
- Testing de componentes aislados

### ✅ **Colaboración en Equipo**
- Diferentes desarrolladores pueden trabajar en features separados
- Menos conflictos de merge
- Responsabilidades claras

## 📋 Convenciones

### **Features**
- Cada feature tiene su propia carpeta
- Contiene: `models/`, `services/`, `screens/`
- Pueden tener: `controllers/`, `repositories/`, `widgets/`

### **Naming**
- Carpetas: `snake_case`
- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables: `camelCase`

### **Imports**
- Imports relativos dentro del mismo feature
- Imports absolutos para features externos
- Shared imports para elementos comunes

## 🚀 Próximos Features a Implementar

```
features/
├── inventory/                     # Gestión de inventario
│   ├── models/
│   ├── services/
│   └── screens/
├── products/                      # Gestión de productos
│   ├── models/
│   ├── services/
│   └── screens/
├── reports/                       # Reportes y análisis
│   ├── models/
│   ├── services/
│   └── screens/
└── settings/                      # Configuraciones
    ├── models/
    ├── services/
    └── screens/
```

## 🛠️ Herramientas y Patrones

- **State Management**: Provider/Riverpod (a implementar)
- **Navigation**: Go Router (a implementar)
- **HTTP Client**: http package
- **Local Storage**: shared_preferences (a restaurar)
- **Testing**: flutter_test + mockito

Esta estructura facilita el desarrollo, mantenimiento y escalabilidad del proyecto Stock Wise.