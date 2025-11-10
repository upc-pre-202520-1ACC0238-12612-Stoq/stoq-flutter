class Product {
  final int id;
  final String name;
  final String date;
  final int stock;
  final String? description;
  final double? price;

  Product({
    required this.id,
    required this.name,
    required this.date,
    required this.stock,
    this.description,
    this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      stock: json['stock'] ?? 0,
      description: json['description'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'stock': stock,
      'description': description,
      'price': price,
    };
  }
}

class DashboardStats {
  final int totalProducts;
  final String providerDate;
  final int movementHistory;
  final int inventoryCount;

  DashboardStats({
    required this.totalProducts,
    required this.providerDate,
    required this.movementHistory,
    required this.inventoryCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: json['totalProducts'] ?? 0,
      providerDate: json['providerDate'] ?? '00/00/00',
      movementHistory: json['movementHistory'] ?? 0,
      inventoryCount: json['inventoryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'providerDate': providerDate,
      'movementHistory': movementHistory,
      'inventoryCount': inventoryCount,
    };
  }
}