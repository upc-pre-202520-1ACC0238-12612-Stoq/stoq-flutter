class Tag {
  final int id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductRequest {
  final String name;
  final String description;
  final double purchasePrice;
  final double salePrice;
  final String internalNotes;
  final int categoryId;
  final int unitId;
  final List<int> tagIds;

  ProductRequest({
    required this.name,
    required this.description,
    required this.purchasePrice,
    required this.salePrice,
    required this.internalNotes,
    required this.categoryId,
    required this.unitId,
    required this.tagIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'internalNotes': internalNotes,
      'categoryId': categoryId,
      'unitId': unitId,
      'tagIds': tagIds,
    };
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final double purchasePrice;
  final double salePrice;
  final String internalNotes;
  final int categoryId;
  final String categoryName;
  final int unitId;
  final String unitName;
  final String unitAbbreviation;
  final List<Tag> tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.purchasePrice,
    required this.salePrice,
    required this.internalNotes,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    required this.unitAbbreviation,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      internalNotes: json['internalNotes'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      unitId: json['unitId'] ?? 0,
      unitName: json['unitName'] ?? '',
      unitAbbreviation: json['unitAbbreviation'] ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tagJson) => Tag.fromJson(tagJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'internalNotes': internalNotes,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'unitId': unitId,
      'unitName': unitName,
      'unitAbbreviation': unitAbbreviation,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}