class CategoryReport {
  final int id;
  final int categoryId;
  final String categoriaNombre;
  final DateTime fechaConsulta;
  final int totalProductos;
  final int stockTotal;
  final double valorTotalInventario;
  final int productosBajoStock;

  CategoryReport({
    required this.id,
    required this.categoryId,
    required this.categoriaNombre,
    required this.fechaConsulta,
    required this.totalProductos,
    required this.stockTotal,
    required this.valorTotalInventario,
    required this.productosBajoStock,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      categoriaNombre: json['categoriaNombre'] ?? '',
      fechaConsulta: DateTime.tryParse(json['fechaConsulta'] ?? '') ?? DateTime.now(),
      totalProductos: json['totalProductos'] ?? 0,
      stockTotal: json['stockTotal'] ?? 0,
      valorTotalInventario: (json['valorTotalInventario'] ?? 0).toDouble(),
      productosBajoStock: json['productosBajoStock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoriaNombre': categoriaNombre,
      'fechaConsulta': fechaConsulta.toIso8601String(),
      'totalProductos': totalProductos,
      'stockTotal': stockTotal,
      'valorTotalInventario': valorTotalInventario,
      'productosBajoStock': productosBajoStock,
    };
  }

  // Getter para fecha formateada
  String get fechaFormateada {
    return '${fechaConsulta.day.toString().padLeft(2, '0')}/${fechaConsulta.month.toString().padLeft(2, '0')}/${fechaConsulta.year}';
  }

  // Getter para hora formateada
  String get horaFormateada {
    return '${fechaConsulta.hour.toString().padLeft(2, '0')}:${fechaConsulta.minute.toString().padLeft(2, '0')}';
  }

  // Getter para porcentaje de productos bajo stock
  double get porcentajeBajoStock {
    if (totalProductos == 0) return 0.0;
    return (productosBajoStock / totalProductos) * 100;
  }
}