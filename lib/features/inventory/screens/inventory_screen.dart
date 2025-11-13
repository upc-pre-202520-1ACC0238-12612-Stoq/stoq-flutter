import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';
import '../widgets/add_inventory_modal.dart';
import '../../products/services/product_service.dart';
import '../../products/models/product_models.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<InventoryProduct> _products = [];
  List<InventoryProduct> _filteredProducts = [];
  bool _isLoading = true;
  bool _showFilters = false;
  bool _showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
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
        _filteredProducts = inventory.productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar inventario: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _searchProducts(String query) {
    setState(() {
      List<InventoryProduct> filtered = _products;

      // Aplicar búsqueda por texto
      if (query.isNotEmpty) {
        filtered = filtered.where((product) =>
          product.productoNombre.toLowerCase().contains(query.toLowerCase()) ||
          product.categoriaNombre.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      // Aplicar filtro de stock bajo si está activo
      if (_showOnlyLowStock) {
        filtered = filtered.where((product) => product.stockBajo).toList();
      }

      _filteredProducts = filtered;
    });
  }

  void _toggleLowStockFilter() {
    setState(() {
      _showOnlyLowStock = !_showOnlyLowStock;
      _searchProducts(_searchController.text); // Reaplica los filtros
    });
  }

  void _showAddInventoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddInventoryModal(
        onInventoryAdded: _onInventoryAdded,
      ),
    );
  }

  void _onInventoryAdded(InventoryProduct product) {
    setState(() {
      // Buscar si el producto ya existe en el inventario
      final existingIndex = _products.indexWhere((p) => p.productoId == product.productoId);
      
      if (existingIndex != -1) {
        // Si existe, actualizar
        _products[existingIndex] = product;
      } else {
        // Si no existe, agregar
        _products.add(product);
      }
      
      _searchProducts(_searchController.text); // Refiltra los productos
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto "${product.productoNombre}" agregado al inventario'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showProductDetails(InventoryProduct product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDetailsDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Inventario por Producto',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Header con búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            color: AppColors.cardBackground,
            child: Column(
              children: [
                // Barra de búsqueda y filtro
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchProducts,
                          decoration: InputDecoration(
                            hintText: 'Buscar producto...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                              vertical: AppSizes.paddingSmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: const Icon(Icons.tune),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                // Filtros (si están activos)
                if (_showFilters) ...[
                  const SizedBox(height: AppSizes.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: AppColors.warning),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Solo productos con stock bajo',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: _showOnlyLowStock,
                          onChanged: (_) => _toggleLowStockFilter(),
                          activeColor: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Estadísticas rápidas
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Productos',
                    '${_products.length}',
                    AppColors.primary,
                    Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: _buildStatCard(
                    'Stock Bajo',
                    '${_products.where((p) => p.stockBajo).length}',
                    AppColors.error,
                    Icons.warning,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: _buildStatCard(
                    'Valor Total',
                    's/. ${_products.fold<double>(0, (sum, p) => sum + p.total).toStringAsFixed(2)}',
                    AppColors.success,
                    Icons.monetization_on,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(),
          ),
        ],
      ),
      
      // Botón flotante para agregar al inventario
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInventoryModal,
        backgroundColor: AppColors.redAccent,
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            _searchController.text.isEmpty && !_showOnlyLowStock
                ? 'No hay productos en el inventario'
                : 'No se encontraron productos',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            _searchController.text.isEmpty && !_showOnlyLowStock
                ? 'Agrega productos al inventario usando el botón +'
                : 'Prueba con otros términos de búsqueda o filtros',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
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
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      borderColor: product.stockBajo 
          ? AppColors.error.withOpacity(0.5) 
          : AppColors.primary.withOpacity(0.3),
      borderWidth: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del producto
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productoNombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoriaNombre,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Estado de stock
              if (product.stockBajo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: AppColors.error, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Stock Bajo',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingMedium),
          
          // Detalles en grid
          Row(
            children: [
              Expanded(
                child: _buildDetailColumn(
                  'Fecha entrada',
                  _formatDate(product.fechaEntrada),
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Cantidad',
                  '${product.cantidad}',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingSmall),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailColumn(
                  'Precio unitario',
                  's/. ${product.precio.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Unidad',
                  '${product.unidadNombre} (${product.unidadAbreviacion})',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingSmall),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailColumn(
                  'Stock mínimo',
                  '${product.stockMinimo}',
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Total valor',
                  's/. ${product.total.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingMedium),
          
          // Botón "Ver detalles"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showProductDetails(product),
              icon: const Icon(Icons.info_outline, color: AppColors.primary),
              label: const Text(
                'Ver Detalles',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ProductDetailsDialog extends StatelessWidget {
  final InventoryProduct product;

  const _ProductDetailsDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(product.productoNombre)),
          if (product.stockBajo)
            Icon(Icons.warning, color: AppColors.error),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('ID', product.id.toString()),
            _buildDetailRow('Categoría', product.categoriaNombre),
            _buildDetailRow('Fecha de Entrada', _formatDate(product.fechaEntrada)),
            _buildDetailRow('Cantidad Actual', product.cantidad.toString()),
            _buildDetailRow('Precio Unitario', 's/. ${product.precio.toStringAsFixed(2)}'),
            _buildDetailRow('Unidad', '${product.unidadNombre} (${product.unidadAbreviacion})'),
            _buildDetailRow('Stock Mínimo', product.stockMinimo.toString()),
            _buildDetailRow('Valor Total', 's/. ${product.total.toStringAsFixed(2)}'),
            _buildDetailRow('Estado', product.stockBajo ? 'Stock Bajo' : 'Stock Normal'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}