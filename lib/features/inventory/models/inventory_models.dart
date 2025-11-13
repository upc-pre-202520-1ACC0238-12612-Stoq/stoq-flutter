class InventoryProduct {
  final int id;
  final int productoId;
  final String productoNombre;
  final String categoriaNombre;
  final String unidadNombre;
  final String unidadAbreviacion;
  final DateTime fechaEntrada;
  final int cantidad;
  final double precio;
  final int stockMinimo;
  final double total;
  final bool stockBajo;

  InventoryProduct({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.categoriaNombre,
    required this.unidadNombre,
    required this.unidadAbreviacion,
    required this.fechaEntrada,
    required this.cantidad,
    required this.precio,
    required this.stockMinimo,
    required this.total,
    required this.stockBajo,
  });

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    return InventoryProduct(
      id: json['id'] ?? 0,
      productoId: json['productoId'] ?? 0,
      productoNombre: json['productoNombre'] ?? '',
      categoriaNombre: json['categoriaNombre'] ?? '',
      unidadNombre: json['unidadNombre'] ?? '',
      unidadAbreviacion: json['unidadAbreviacion'] ?? '',
      fechaEntrada: DateTime.tryParse(json['fechaEntrada'] ?? '') ?? DateTime.now(),
      cantidad: json['cantidad'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
      stockMinimo: json['stockMinimo'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      stockBajo: json['stockBajo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'categoriaNombre': categoriaNombre,
      'unidadNombre': unidadNombre,
      'unidadAbreviacion': unidadAbreviacion,
      'fechaEntrada': fechaEntrada.toIso8601String(),
      'cantidad': cantidad,
      'precio': precio,
      'stockMinimo': stockMinimo,
      'total': total,
      'stockBajo': stockBajo,
    };
  }
}

class InventoryBatch {
  final int id;
  final int productoId;
  final String productoNombre;
  final String unidadNombre;
  final String unidadAbreviacion;
  final String proveedor;
  final DateTime fechaEntrada;
  final int cantidad;
  final double precio;
  final double total;

  InventoryBatch({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.unidadNombre,
    required this.unidadAbreviacion,
    required this.proveedor,
    required this.fechaEntrada,
    required this.cantidad,
    required this.precio,
    required this.total,
  });

  factory InventoryBatch.fromJson(Map<String, dynamic> json) {
    return InventoryBatch(
      id: json['id'] ?? 0,
      productoId: json['productoId'] ?? 0,
      productoNombre: json['productoNombre'] ?? '',
      unidadNombre: json['unidadNombre'] ?? '',
      unidadAbreviacion: json['unidadAbreviacion'] ?? '',
      proveedor: json['proveedor'] ?? '',
      fechaEntrada: DateTime.tryParse(json['fechaEntrada'] ?? '') ?? DateTime.now(),
      cantidad: json['cantidad'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'unidadNombre': unidadNombre,
      'unidadAbreviacion': unidadAbreviacion,
      'proveedor': proveedor,
      'fechaEntrada': fechaEntrada.toIso8601String(),
      'cantidad': cantidad,
      'precio': precio,
      'total': total,
    };
  }
}

class InventoryResponse {
  final List<InventoryProduct> productos;
  final List<InventoryBatch> lotes;

  InventoryResponse({
    required this.productos,
    required this.lotes,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryResponse(
      productos: (json['productos'] as List<dynamic>?)
              ?.map((item) => InventoryProduct.fromJson(item))
              .toList() ??
          [],
      lotes: (json['lotes'] as List<dynamic>?)
              ?.map((item) => InventoryBatch.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productos': productos.map((p) => p.toJson()).toList(),
      'lotes': lotes.map((l) => l.toJson()).toList(),
    };
  }
}

class AddInventoryRequest {
  final int productoId;
  final int cantidad;
  final double precio;
  final int stockMinimo;

  AddInventoryRequest({
    required this.productoId,
    required this.cantidad,
    required this.precio,
    required this.stockMinimo,
  });

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'cantidad': cantidad,
      'precio': precio,
      'stockMinimo': stockMinimo,
    };
  }
}