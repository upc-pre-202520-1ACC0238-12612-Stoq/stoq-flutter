import 'package:flutter/material.dart';

class Transfer {
  final String id;
  final String productId;
  final String productName;
  final String fromBranchId;
  final String fromBranchName;
  final String toBranchId;
  final String toBranchName;
  final int quantity;
  final DateTime transferDate;
  final String status; // 'pending', 'in_transit', 'completed', 'cancelled'
  final String? notes;

  const Transfer({
    required this.id,
    required this.productId,
    required this.productName,
    required this.fromBranchId,
    required this.fromBranchName,
    required this.toBranchId,
    required this.toBranchName,
    required this.quantity,
    required this.transferDate,
    this.status = 'pending',
    this.notes,
  });

  Color get statusColor {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_transit': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'in_transit': return 'En Tránsito';
      case 'completed': return 'Completado';
      case 'cancelled': return 'Cancelado';
      default: return 'Desconocido';
    }
  }

  // Transferencias de ejemplo
  static List<Transfer> get sampleTransfers => [
    Transfer(
      id: '1',
      productId: '1',
      productName: 'Leche',
      fromBranchId: '4',
      fromBranchName: 'Almacén Este',
      toBranchId: '2',
      toBranchName: 'Sucursal Norte',
      quantity: 50,
      transferDate: DateTime(2024, 5, 20),
      status: 'completed',
      notes: 'Reabastecimiento semanal',
    ),
    Transfer(
      id: '2',
      productId: '2',
      productName: 'Arroz',
      fromBranchId: '1',
      fromBranchName: 'Sede Central',
      toBranchId: '3',
      toBranchName: 'Sucursal Sur',
      quantity: 30,
      transferDate: DateTime(2024, 5, 21),
      status: 'in_transit',
      notes: 'Stock bajo en sucursal sur',
    ),
    Transfer(
      id: '3',
      productId: '3',
      productName: 'Aceite',
      fromBranchId: '4',
      fromBranchName: 'Almacén Este',
      toBranchId: '1',
      toBranchName: 'Sede Central',
      quantity: 20,
      transferDate: DateTime(2024, 5, 22),
      status: 'pending',
      notes: 'Para venta mayorista',
    ),
  ];
}