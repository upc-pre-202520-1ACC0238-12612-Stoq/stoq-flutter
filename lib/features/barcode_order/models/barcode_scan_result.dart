class BarcodeScanResult {
  final int productId;
  final String productName;
  final double unitPrice;
  final String unit;
  final int availableStock;
  final String? barcode;

  BarcodeScanResult({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unit,
    required this.availableStock,
    this.barcode,
  });

  factory BarcodeScanResult.fromJson(Map<String, dynamic> json) {
    return BarcodeScanResult(
      productId: json['id'] ?? json['productId'] ?? 0,
      productName: json['name'] ?? json['productName'] ?? json['productoNombre'] ?? '',
      unitPrice: (json['price'] ?? json['unitPrice'] ?? json['precio'] ?? 0).toDouble(),
      unit: json['unit'] ?? json['unidadAbreviacion'] ?? 'und',
      availableStock: json['stock'] ?? json['availableStock'] ?? json['cantidad'] ?? 0,
      barcode: json['barcode'] ?? json['codigoBarras'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'unit': unit,
      'availableStock': availableStock,
      'barcode': barcode,
    };
  }
}
