class SaleResponse {
  final String id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;
  final String customerName;
  final String? notes;
  final DateTime createdAt;
  final String status;
  final String? branchId;

  SaleResponse({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.customerName,
    this.notes,
    required this.createdAt,
    required this.status,
    this.branchId,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    // Calcular total si no viene en el response
    final quantity = json['quantity'] ?? 0;
    final unitPrice = (json['unitPrice'] ?? 0).toDouble();
    final total = json['total'] ?? (quantity * unitPrice);

    return SaleResponse(
      id: json['id']?.toString() ?? '',
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? json['productNombre'] ?? 'Producto sin nombre',
      quantity: quantity,
      unitPrice: unitPrice,
      total: total.toDouble(),
      customerName: json['customerName'] ?? 'Cliente sin nombre',
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'completed',
      branchId: json['branchId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'customerName': customerName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'branchId': branchId,
    };
  }

  // Helper methods
  String get formattedTotal => 'S/. ${total.toStringAsFixed(2)}';
  String get formattedUnitPrice => 'S/. ${unitPrice.toStringAsFixed(2)}';
  String get formattedDate => '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

  @override
  String toString() {
    return 'SaleResponse(id: $id, product: $productName, quantity: $quantity, total: $formattedTotal)';
  }
}