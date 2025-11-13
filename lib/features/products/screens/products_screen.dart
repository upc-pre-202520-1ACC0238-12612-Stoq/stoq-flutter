import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/product_models.dart';
import '../services/product_service.dart';
import '../widgets/add_product_modal.dart';
import '../../dashboard/screens/scan_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar productos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.tags.any((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }
    });
  }

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductModal(
        onProductAdded: _onProductAdded,
      ),
    );
  }

  void _onProductAdded(Product product) {
    setState(() {
      _products.add(product);
      _searchProducts(_searchController.text); // Refiltra los productos
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto "${product.name}" agregado exitosamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showProductDetails(Product product) {
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
        title: 'Agregar Producto',
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
                            hintText: 'Buscar Productos',
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
                    child: const Text(
                      'Filtros - Próximamente',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
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
      
      // Botones flotantes
      floatingActionButton: Stack(
        children: [
          // Botón Agregar Producto
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: _showAddProductModal,
              backgroundColor: AppColors.redAccent,
              heroTag: "add",
              child: const Icon(Icons.add, color: AppColors.textLight),
            ),
          ),
          // Botón Escanear Producto
          Positioned(
            bottom: 70,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanProductScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.black,
              heroTag: "scan",
              child: const Icon(Icons.camera_alt, color: AppColors.textLight),
            ),
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
            _searchController.text.isEmpty 
                ? 'No hay productos registrados'
                : 'No se encontraron productos',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            _searchController.text.isEmpty
                ? 'Agrega tu primer producto usando el botón +'
                : 'Prueba con otros términos de búsqueda',
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

  Widget _buildProductCard(Product product) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      borderColor: AppColors.primary.withOpacity(0.3),
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
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Iconos de acción
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de stock (azul, como en el mockup)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Stock',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingSmall),
          
          // Descripción
          if (product.description.isNotEmpty) ...[
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
          ],
          
          // Tags
          if (product.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: product.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
          ],
          
          // Botón "Detalle"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showProductDetails(product),
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text(
                'Detalle',
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
}

class _ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const _ProductDetailsDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(product.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Categoría', product.categoryName),
            _buildDetailRow('Descripción', product.description),
            _buildDetailRow('Precio de Compra', '\$${product.purchasePrice.toStringAsFixed(2)}'),
            _buildDetailRow('Precio de Venta', '\$${product.salePrice.toStringAsFixed(2)}'),
            _buildDetailRow('Unidad', '${product.unitName} (${product.unitAbbreviation})'),
            if (product.internalNotes.isNotEmpty)
              _buildDetailRow('Notas Internas', product.internalNotes),
            if (product.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: product.tags.map((tag) => Chip(
                  label: Text(tag.name),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                )).toList(),
              ),
            ],
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
            child: Text(value.isEmpty ? 'N/A' : value),
          ),
        ],
      ),
    );
  }
}