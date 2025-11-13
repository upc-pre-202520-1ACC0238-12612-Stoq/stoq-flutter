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
    // Formatear fecha desde la API
    String formattedDate = '';
    try {
      if (json['createdAt'] != null) {
        final dateTime = DateTime.parse(json['createdAt']);
        formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }
    } catch (e) {
      formattedDate = 'Sin fecha';
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: formattedDate,
      stock: 0, // Por defecto, ya que no viene en la API de productos
      description: json['description'],
      price: (json['salePrice'] ?? json['price'])?.toDouble(),
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
  final int movementsToday;

  DashboardStats({
    required this.totalProducts,
    required this.movementsToday,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: json['totalProducts'] ?? 0,
      movementsToday: json['movementsToday'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'movementsToday': movementsToday,
    };
  }
}