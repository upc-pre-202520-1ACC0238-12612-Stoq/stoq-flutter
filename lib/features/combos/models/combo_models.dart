class ComboItem {
  final int id;
  final int productId;
  final String productName;
  final String productDescription;
  final double productPrice;
  final int quantity;

  ComboItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.quantity,
  });

  factory ComboItem.fromJson(Map<String, dynamic> json) {
    return ComboItem(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productPrice: (json['productPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'quantity': quantity,
    };
  }
}

class Combo {
  final int id;
  final String name;
  final List<ComboItem> items;

  Combo({
    required this.id,
    required this.name,
    required this.items,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ComboItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Calcular precio total del combo
  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + (item.productPrice * item.quantity));
  }

  // Obtener cantidad total de productos
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class ComboItemRequest {
  final int productId;
  final int quantity;

  ComboItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class ComboRequest {
  final String name;
  final List<ComboItemRequest> items;

  ComboRequest({
    required this.name,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}