import 'package:flutter/material.dart';

class Branch {
  final String id;
  final String name;
  final String type; // 'central', 'sucursal', 'almacen'
  final double latitude;
  final double longitude;
  final int stockTotal;
  final int alertLevel; // Nivel de alerta de stock
  final String address;

  const Branch({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.stockTotal,
    this.alertLevel = 0,
    this.address = '',
  });

  // Factory constructor para parsear JSON del API
  factory Branch.fromJson(Map<String, dynamic> json) {
    // Calcular alertLevel basado en stockTotal
    int alert = 0;
    if (json['stockTotal'] < 500) {
      alert = 2; // Crítico
    } else if (json['stockTotal'] < 1000) {
      alert = 1; // Medio
    }

    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'sucursal',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      stockTotal: json['stockTotal'] ?? 0,
      alertLevel: alert,
      address: json['address'] ?? '',
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? 0,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'stockTotal': stockTotal,
      'address': address,
    };
  }

  // Sedes de ejemplo enriquecidas
  static List<Branch> get sampleBranches => [
    Branch(
      id: '1',
      name: 'Sede Central',
      type: 'central',
      latitude: -12.0464,
      longitude: -77.0428,
      stockTotal: 1500,
      address: 'Av. Principal 123',
    ),
    Branch(
      id: '2',
      name: 'Sucursal Norte', 
      type: 'sucursal',
      latitude: -12.0264,
      longitude: -77.0328,
      stockTotal: 800,
      alertLevel: 1, // Alerta media
      address: 'Av. Norte 456',
    ),
    Branch(
      id: '3',
      name: 'Sucursal Sur',
      type: 'sucursal',
      latitude: -12.0664, 
      longitude: -77.0528,
      stockTotal: 300,
      alertLevel: 2, // Alerta alta
      address: 'Av. Sur 789',
    ),
    Branch(
      id: '4',
      name: 'Almacén Este',
      type: 'almacen',
      latitude: -12.0364,
      longitude: -77.0628,
      stockTotal: 2000,
      address: 'Calle Almacén 321',
    ),
  ];

  // Helper para color según nivel de alerta
  Color get alertColor {
    switch (alertLevel) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      default: return Colors.grey;
    }
  }

  // Helper para icono según tipo
  IconData get typeIcon {
    switch (type) {
      case 'central': return Icons.business;
      case 'sucursal': return Icons.store;
      case 'almacen': return Icons.warehouse;
      default: return Icons.location_on;
    }
  }

  // Sobrescribir == y hashCode para comparación por ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Branch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}