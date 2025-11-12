class Product {
  final String id;
  final String name;
  final String provider;
  final DateTime entryDate;
  final int quantityPerUnit;
  final double pricePerUnit;
  final String unit;
  
  // NUEVO: Stock por sede
  final Map<String, int> stockByBranch; // {'branch_id': cantidad}

  const Product({
    required this.id,
    required this.name,
    required this.provider,
    required this.entryDate,
    required this.quantityPerUnit,
    required this.pricePerUnit,
    required this.unit,
    required this.stockByBranch,
  });

  // Stock total consolidado
  int get totalStock {
    return stockByBranch.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // Stock en una sede específica
  int stockInBranch(String branchId) {
    return stockByBranch[branchId] ?? 0;
  }

  // Datos de ejemplo multi-sede
  static List<Product> get sampleProducts => [
    Product(
      id: '1',
      name: 'Leche',
      provider: 'Rosaura Lopez',
      entryDate: DateTime(2024, 4, 14),
      quantityPerUnit: 20,
      pricePerUnit: 5.0,
      unit: 'ml',
      stockByBranch: {
        '1': 800,  // Sede Central
        '2': 300,  // Sucursal Norte
        '3': 200,  // Sucursal Sur
        '4': 200,  // Almacén Este
      },
    ),
    Product(
      id: '2',
      name: 'Arroz',
      provider: 'Granos SAC',
      entryDate: DateTime(2024, 4, 15),
      quantityPerUnit: 1,
      pricePerUnit: 3.5,
      unit: 'kg',
      stockByBranch: {
        '1': 400,
        '2': 200,
        '3': 100,
        '4': 300,
      },
    ),
    Product(
      id: '3',
      name: 'Aceite',
      provider: 'Aceites Premium',
      entryDate: DateTime(2024, 4, 12),
      quantityPerUnit: 1,
      pricePerUnit: 8.0,
      unit: 'lt',
      stockByBranch: {
        '1': 150,
        '2': 80,
        '3': 45,
        '4': 100,
      },
    ),
  ];

  // Método para transferir stock entre sedes
  Product transferStock({
    required String fromBranchId,
    required String toBranchId,
    required int quantity,
  }) {
    final currentFromStock = stockByBranch[fromBranchId] ?? 0;
    final currentToStock = stockByBranch[toBranchId] ?? 0;

    if (currentFromStock < quantity) {
      throw Exception('Stock insuficiente en sede origen');
    }

    final newStockByBranch = Map<String, int>.from(stockByBranch);
    newStockByBranch[fromBranchId] = currentFromStock - quantity;
    newStockByBranch[toBranchId] = currentToStock + quantity;

    return Product(
      id: id,
      name: name,
      provider: provider,
      entryDate: entryDate,
      quantityPerUnit: quantityPerUnit,
      pricePerUnit: pricePerUnit,
      unit: unit,
      stockByBranch: newStockByBranch,
    );
  }
}