class StockCheck {
  final int productId;
  final String productName;
  final int availableStock;
  final double unitPrice;
  final String unit;
  final bool hasStock;
  final DateTime lastUpdated;

  StockCheck({
    required this.productId,
    required this.productName,
    required this.availableStock,
    required this.unitPrice,
    required this.unit,
    required this.hasStock,
    required this.lastUpdated,
  });

  factory StockCheck.fromJson(Map<String, dynamic> json) {
    final stock = json['availableStock'] ?? json['cantidad'] ?? 0;

    return StockCheck(
      productId: json['productId'] ?? json['productoId'] ?? 0,
      productName: json['productName'] ?? json['productoNombre'] ?? 'Producto sin nombre',
      availableStock: stock,
      unitPrice: (json['unitPrice'] ?? json['precio'] ?? 0).toDouble(),
      unit: json['unit'] ?? json['unidad'] ?? 'unidad',
      hasStock: stock > 0,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? json['lastUpdate'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper methods para validación de stock
  bool canSellQuantity(int requestedQuantity) {
    return availableStock >= requestedQuantity;
  }

  int get maxSellableQuantity => availableStock;

  String get formattedStock => '$availableStock $unit';
  String get formattedPrice => 'S/. ${unitPrice.toStringAsFixed(2)}';

  // Estado del stock para UI
  String get stockStatus {
    if (availableStock == 0) return 'Agotado';
    if (availableStock <= 5) return 'Stock Bajo';
    return 'Disponible';
  }

  // Color según estado de stock
  String get stockStatusColor {
    if (availableStock == 0) return 'red';
    if (availableStock <= 5) return 'orange';
    return 'green';
  }

  @override
  String toString() {
    return 'StockCheck(product: $productName, stock: $formattedStock, price: $formattedPrice)';
  }
}