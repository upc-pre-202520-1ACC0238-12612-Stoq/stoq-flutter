import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';
import 'create_inventory_screen.dart';
import '../services/inventory_service.dart';
import '../models/inventory_models.dart';

class InventoryByBatchScreen extends StatefulWidget {
  const InventoryByBatchScreen({super.key});

  @override
  State<InventoryByBatchScreen> createState() => _InventoryByBatchScreenState();
}

class AdvancedSearchModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;

  const AdvancedSearchModal({super.key, required this.onFiltersApplied});

  @override
  State<AdvancedSearchModal> createState() => _AdvancedSearchModalState();
}

class _AdvancedSearchModalState extends State<AdvancedSearchModal> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime? _selectedDate;
  bool _hasStock = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _applyFilters() {
    final filters = {
      'product': _productController.text.trim(),
      'provider': _providerController.text.trim(),
      'entryDate': _selectedDate,
      'quantity': _quantityController.text.trim(),
      'price': _priceController.text.trim(),
      'hasStock': _hasStock,
    };
    
    widget.onFiltersApplied(filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _productController.clear();
      _providerController.clear();
      _quantityController.clear();
      _priceController.clear();
      _selectedDate = null;
      _hasStock = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Búsqueda Avanzada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Filtro: Producto
                  _buildFilterField(
                    controller: _productController,
                    label: 'Producto',
                    hintText: 'Ej: Leche, Arroz, Pan...',
                    icon: Icons.shopping_basket,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),

                  // Filtro: Proveedor
                  _buildFilterField(
                    controller: _providerController,
                    label: 'Proveedor',
                    hintText: 'Ej: Rosaura Lopez, Granos SAC...',
                    icon: Icons.business,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),

                  // Filtro: Fecha de ingreso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de ingreso',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, 
                                  size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: _selectedDate != null 
                                      ? AppColors.textPrimary 
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedDate != null)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = null;
                                    });
                                  },
                                  icon: const Icon(Icons.clear, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),

                  // Filtros: Cantidad y Precio en fila
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterField(
                          controller: _quantityController,
                          label: 'Cantidad mínima',
                          hintText: 'Ej: 10',
                          icon: Icons.format_list_numbered,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: _buildFilterField(
                          controller: _priceController,
                          label: 'Precio máximo',
                          hintText: 'Ej: 50.00',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          prefixText: 's/. ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),

                  // Filtro: Solo con stock
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2, 
                            size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Solo productos con stock disponible',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value: _hasStock,
                          onChanged: (value) {
                            setState(() {
                              _hasStock = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                            ),
                            side: BorderSide(color: AppColors.primary),
                          ),
                          child: Text(
                            'Limpiar Filtros',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                            ),
                          ),
                          child: const Text(
                            'Aplicar Filtros',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
          ),
        ),
      ],
    );
  }
}

class _InventoryByBatchScreenState extends State<InventoryByBatchScreen> {
  final InventoryService _inventoryService = InventoryService();
  int _selectedView = 0; // 0: Por producto, 1: Por lote
  final TextEditingController _searchController = TextEditingController();
  
  // Datos desde la API
  List<InventoryProduct> _products = [];
  List<InventoryBatch> _batches = [];
  List<InventoryProduct> _filteredProducts = [];
  List<InventoryBatch> _filteredBatches = [];
  bool _isLoading = true;
  Map<String, dynamic>? _appliedFilters;

  @override
  void initState() {
    super.initState();
    _loadInventory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inventory = await _inventoryService.getInventory();
      setState(() {
        _products = inventory.productos;
        _batches = inventory.lotes;
        _filteredProducts = inventory.productos;
        _filteredBatches = inventory.lotes;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar inventario: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      // Filtrar productos
      _filteredProducts = _products.where((product) {
        if (query.isEmpty) return true;
        return product.productoNombre.toLowerCase().contains(query) ||
               product.categoriaNombre.toLowerCase().contains(query);
      }).toList();

      // Filtrar lotes
      _filteredBatches = _batches.where((batch) {
        if (query.isEmpty) return true;
        return batch.productoNombre.toLowerCase().contains(query) ||
               batch.proveedor.toLowerCase().contains(query);
      }).toList();

      // Aplicar filtros avanzados si existen
      if (_appliedFilters != null) {
        _filteredProducts = _applyAdvancedFilters(_filteredProducts);
        _filteredBatches = _applyAdvancedFiltersBatches(_filteredBatches);
      }
    });
  }

  List<InventoryProduct> _applyAdvancedFilters(List<InventoryProduct> products) {
    var filtered = products;
    
    if (_appliedFilters?['product'] != null && _appliedFilters!['product'].toString().isNotEmpty) {
      final productFilter = _appliedFilters!['product'].toString().toLowerCase();
      filtered = filtered.where((p) => 
        p.productoNombre.toLowerCase().contains(productFilter)
      ).toList();
    }

    if (_appliedFilters?['quantity'] != null && _appliedFilters!['quantity'].toString().isNotEmpty) {
      final minQuantity = int.tryParse(_appliedFilters!['quantity'].toString());
      if (minQuantity != null) {
        filtered = filtered.where((p) => p.cantidad >= minQuantity).toList();
      }
    }

    if (_appliedFilters?['price'] != null && _appliedFilters!['price'].toString().isNotEmpty) {
      final maxPrice = double.tryParse(_appliedFilters!['price'].toString());
      if (maxPrice != null) {
        filtered = filtered.where((p) => p.precio <= maxPrice).toList();
      }
    }

    return filtered;
  }

  List<InventoryBatch> _applyAdvancedFiltersBatches(List<InventoryBatch> batches) {
    var filtered = batches;
    
    if (_appliedFilters?['product'] != null && _appliedFilters!['product'].toString().isNotEmpty) {
      final productFilter = _appliedFilters!['product'].toString().toLowerCase();
      filtered = filtered.where((b) => 
        b.productoNombre.toLowerCase().contains(productFilter)
      ).toList();
    }

    if (_appliedFilters?['provider'] != null && _appliedFilters!['provider'].toString().isNotEmpty) {
      final providerFilter = _appliedFilters!['provider'].toString().toLowerCase();
      filtered = filtered.where((b) => 
        b.proveedor.toLowerCase().contains(providerFilter)
      ).toList();
    }

    if (_appliedFilters?['entryDate'] != null) {
      final filterDate = _appliedFilters!['entryDate'] as DateTime;
      filtered = filtered.where((b) => 
        b.fechaEntrada.year == filterDate.year &&
        b.fechaEntrada.month == filterDate.month &&
        b.fechaEntrada.day == filterDate.day
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          child: LogoWidget(size: 40),
        ),
        title: const Text(
          'Inventario por Lote',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAdvancedSearch,
            icon: const Icon(Icons.filter_alt, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: _generateNew,
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de vista
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildViewOption(
                      text: 'Por producto',
                      isSelected: _selectedView == 0,
                      onTap: () => setState(() => _selectedView = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildViewOption(
                      text: 'Por lote',
                      isSelected: _selectedView == 1,
                      onTap: () => setState(() => _selectedView = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _selectedView == 0 ? 'Buscar producto...' : 'Buscar lote...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingMedium,
                ),
              ),
              onChanged: (value) {
                _applyFilters();
              },
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Botón Generar nuevo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateNew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                ),
                child: Text(
                  _selectedView == 0 ? 'Agregar Producto' : 'Crear Nuevo Lote',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Búsqueda avanzada
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Búsqueda avanzada',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showAdvancedSearch,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Contenido dinámico según la vista seleccionada
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _selectedView == 0 
                    ? _buildProductsView()  // Vista por producto
                    : _buildBatchesView(),   // Vista por lote
          ),
        ],
      ),
    );
  }

  Widget _buildViewOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // VISTA POR PRODUCTO
  Widget _buildProductsView() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(InventoryProduct product) {
    final entryDate = '${product.fechaEntrada.day.toString().padLeft(2, '0')}/${product.fechaEntrada.month.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del producto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    product.productoNombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Proveedor',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    product.categoriaNombre,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Detalles del producto
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de entrada',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      entryDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad por unidad',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${product.cantidad}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio por unidad',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      's/. ${product.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unidad de medida',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      product.unidadAbreviacion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Stock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${product.cantidad}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // VISTA POR LOTE
  Widget _buildBatchesView() {
    if (_filteredBatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'No hay lotes disponibles',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _filteredBatches.length,
      itemBuilder: (context, index) {
        final batch = _filteredBatches[index];
        return _buildBatchCard(batch);
      },
    );
  }

  Widget _buildBatchCard(InventoryBatch batch) {
    final entryDate = '${batch.fechaEntrada.day.toString().padLeft(2, '0')}/${batch.fechaEntrada.month.toString().padLeft(2, '0')}/${batch.fechaEntrada.year}';
    final batchNumber = 'LOTE-${batch.id.toString().padLeft(3, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del lote
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lote',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    batchNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Producto y Proveedor
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producto',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      batch.productoNombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proveedor',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      batch.proveedor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Fechas
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de entrada',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      entryDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de vencimiento',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'N/A', // La API no proporciona fecha de vencimiento
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Cantidades
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad total',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${batch.cantidad} ${batch.unidadAbreviacion}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${batch.cantidad} ${batch.unidadAbreviacion}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAdvancedSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AdvancedSearchModal(
          onFiltersApplied: (filters) {
            setState(() {
              _appliedFilters = filters;
            });
            _applyFilters();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtros aplicados'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _generateNew() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateInventoryScreen(),
      ),
    );
  }
}
