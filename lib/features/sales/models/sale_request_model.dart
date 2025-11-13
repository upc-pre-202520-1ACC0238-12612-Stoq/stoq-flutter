class SaleRequest {
  final int productId;
  final int quantity;
  final double unitPrice;
  final String customerName;
  final String? notes;

  SaleRequest({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.customerName,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'customerName': customerName,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  @override
  String toString() {
    return 'SaleRequest(productId: $productId, quantity: $quantity, unitPrice: $unitPrice, customerName: $customerName)';
  }
}