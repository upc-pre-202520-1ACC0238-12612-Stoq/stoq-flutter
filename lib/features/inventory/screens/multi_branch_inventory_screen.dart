import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/branch_model.dart';
//import '../models/transfer_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';
import 'create_transfer_screen.dart';

class MultiBranchInventoryScreen extends StatefulWidget {
  const MultiBranchInventoryScreen({super.key});

  @override
  State<MultiBranchInventoryScreen> createState() => _MultiBranchInventoryScreenState();
}

class _MultiBranchInventoryScreenState extends State<MultiBranchInventoryScreen> {
  String _selectedBranchId = 'all'; // 'all' para vista consolidada
  final List<Product> _products = Product.sampleProducts;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const LogoWidget(size: 40),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showTransferHistory,
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: _createNewTransfer,
            icon: const Icon(Icons.swap_horiz, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de sede
          _buildBranchSelector(),
          
          // Resumen de stock
          _buildStockSummary(),
          
          // Lista de productos
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: AppColors.cardBackground,
      child: DropdownButton<String>(
        value: _selectedBranchId,
        isExpanded: true,
        onChanged: (String? newValue) {
          setState(() {
            _selectedBranchId = newValue!;
          });
        },
        items: [
          const DropdownMenuItem(
            value: 'all',
            child: Text('📊 Vista Consolidada - Todas las Sedes'),
          ),
          ...Branch.sampleBranches.map((branch) {
            return DropdownMenuItem(
              value: branch.id,
              child: Row(
                children: [
                  Icon(branch.typeIcon, size: 16, color: branch.alertColor),
                  const SizedBox(width: 8),
                  Text('${branch.name} (${_calculateBranchStock(branch.id)})'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStockSummary() {
    final totalStock = _selectedBranchId == 'all' 
        ? _products.fold(0, (sum, product) => sum + product.totalStock)
        : _products.fold(0, (sum, product) => sum + product.stockInBranch(_selectedBranchId));

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.primary30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Stock Total', '$totalStock unidades'),
          _buildSummaryItem('Productos', '${_products.length} tipos'),
          _buildSummaryItem('Sedes', _selectedBranchId == 'all' 
              ? '${Branch.sampleBranches.length}' 
              : '1'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    final productsToShow = _selectedBranchId == 'all'
        ? _products
        : _products.where((product) => product.stockInBranch(_selectedBranchId) > 0).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: productsToShow.length,
      itemBuilder: (context, index) {
        final product = productsToShow[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del producto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary10, 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedBranchId == 'all'
                        ? 'Total: ${product.totalStock}'
                        : 'Stock: ${product.stockInBranch(_selectedBranchId)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Detalles del producto
            Text(
              'Proveedor: ${product.provider}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 8),
            
            // Stock por sede (solo en vista consolidada)
            if (_selectedBranchId == 'all') ...[
              _buildBranchStockDistribution(product),
              const SizedBox(height: 8),
            ],
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _adjustStock(product),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Ajustar Stock'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _transferProduct(product),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Transferir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchStockDistribution(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución por Sede:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: Branch.sampleBranches.map((branch) {
            final stock = product.stockInBranch(branch.id);
            if (stock > 0) {
              return Chip(
                label: Text('${branch.name}: $stock'),
                backgroundColor: branch.alertColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: branch.alertColor,
                  fontSize: 10,
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ),
      ],
    );
  }

  int _calculateBranchStock(String branchId) {
    return _products.fold(0, (sum, product) => sum + product.stockInBranch(branchId));
  }

  void _showTransferHistory() {
    if (mounted) {
    // Navegar a pantalla de historial de transferencias
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad: Historial de Transferencias'),
        backgroundColor: AppColors.info,
      ),
    );
    } 
  }

  void _createNewTransfer() {
    if (mounted) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateTransferScreen(),
    ),
  ).then((transfer) {
    if (transfer != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transferencia de ${transfer.productName} creada'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  });
  } 
}

  void _adjustStock(Product product) {
    if (mounted) {
    // Navegar a pantalla de ajuste de stock
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajustar stock de: ${product.name}'),
        backgroundColor: AppColors.warning,
      ),
    );
    } 
  }

  void _transferProduct(Product product) {
    if (mounted) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateTransferScreen(preselectedProduct: product),
    ),
  ).then((transfer) {
    if (transfer != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transferencia de ${product.name} creada'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  });
  } 
}
}