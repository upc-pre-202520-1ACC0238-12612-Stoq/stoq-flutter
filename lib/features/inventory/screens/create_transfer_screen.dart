import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/branch_model.dart';
import '../models/transfer_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../services/inventory_service.dart';

class CreateTransferScreen extends StatefulWidget {
  final Product? preselectedProduct;

  const CreateTransferScreen({super.key, this.preselectedProduct});

  @override
  State<CreateTransferScreen> createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen> {
  final InventoryService _inventoryService = InventoryService();
  Product? _selectedProduct;
  Branch? _selectedFromBranch;
  Branch? _selectedToBranch;
  int _transferQuantity = 1;
  final TextEditingController _notesController = TextEditingController();
  
  // Productos desde la API convertidos a Product
  List<Product> _availableProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    // Si se preseleccionó un producto, usarlo
    if (widget.preselectedProduct != null) {
      _selectedProduct = widget.preselectedProduct;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inventory = await _inventoryService.getInventory();
      
      // Convertir InventoryProduct a Product para compatibilidad
      final products = inventory.productos.map((ip) {
        // Crear stock distribuido entre las sedes (simulado)
        final stockByBranch = <String, int>{};
        for (var branch in Branch.sampleBranches) {
          // Distribuir el stock total entre las sedes de manera proporcional
          stockByBranch[branch.id] = (ip.cantidad / Branch.sampleBranches.length).round();
        }
        
        return Product(
          id: ip.productoId.toString(),
          name: ip.productoNombre,
          provider: ip.categoriaNombre,
          entryDate: ip.fechaEntrada,
          quantityPerUnit: ip.cantidad,
          pricePerUnit: ip.precio,
          unit: ip.unidadAbreviacion,
          stockByBranch: stockByBranch,
        );
      }).toList();

      setState(() {
        _availableProducts = products;
        _isLoading = false;
        
        // Si hay un producto preseleccionado, buscarlo en la lista
        if (widget.preselectedProduct != null) {
          _selectedProduct = _availableProducts.firstWhere(
            (p) => p.id == widget.preselectedProduct!.id,
            orElse: () => _availableProducts.isNotEmpty ? _availableProducts.first : widget.preselectedProduct!,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Si falla, usar productos de ejemplo
        _availableProducts = Product.sampleProducts;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar productos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
            onPressed: _validateAndCreateTransfer,
            icon: const Icon(Icons.check, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva Transferencia',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Selección de Producto
            _buildProductSelector(),
            const SizedBox(height: AppSizes.paddingLarge),

            // Selección de Sede Origen
            _buildBranchSelector(
              title: 'Sede Origen',
              selectedBranch: _selectedFromBranch,
              onBranchSelected: (branch) => setState(() => _selectedFromBranch = branch),
              branchType: 'from',
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Selección de Sede Destino
            _buildBranchSelector(
              title: 'Sede Destino', 
              selectedBranch: _selectedToBranch,
              onBranchSelected: (branch) => setState(() => _selectedToBranch = branch),
              branchType: 'to',
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Cantidad a Transferir
            _buildQuantitySelector(),
            const SizedBox(height: AppSizes.paddingLarge),

            // Notas
            _buildNotesField(),
            const SizedBox(height: AppSizes.paddingLarge),

            // Resumen y Validación
            _buildTransferSummary(),
            const SizedBox(height: AppSizes.paddingLarge),

            // Botón Crear Transferencia
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Producto a Transferir',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : DropdownButton<Product>(
                  value: _selectedProduct,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: _availableProducts.isEmpty
                      ? const Text('No hay productos disponibles')
                      : const Text('Selecciona un producto'),
                  onChanged: _availableProducts.isEmpty
                      ? null
                      : (Product? newProduct) {
                          setState(() {
                            _selectedProduct = newProduct;
                            _selectedFromBranch = null;
                            _selectedToBranch = null;
                            _transferQuantity = 1;
                          });
                        },
                  items: _availableProducts.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} (Stock total: ${product.totalStock})'),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildBranchSelector({
    required String title,
    required Branch? selectedBranch,
    required Function(Branch) onBranchSelected,
    required String branchType,
  }) {
    final availableBranches = _getAvailableBranches(branchType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          child: DropdownButton<Branch>(
            value: selectedBranch != null && availableBranches.isNotEmpty
                ? availableBranches.firstWhere(
                    (b) => b.id == selectedBranch.id,
                    orElse: () => availableBranches.first,
                  )
                : null,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text('Selecciona sede $branchType'),
            onChanged: availableBranches.isEmpty ? null : (Branch? newBranch) {
              if (newBranch != null) {
                onBranchSelected(newBranch);
              }
            },
            items: availableBranches.map((branch) {
              final stockInfo = _selectedProduct != null
                  ? ' - Stock: ${_selectedProduct!.stockInBranch(branch.id)}'
                  : '';
              
              return DropdownMenuItem<Branch>(
                value: branch,
                child: Row(
                  children: [
                    Icon(branch.typeIcon, size: 16, color: branch.alertColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${branch.name}$stockInfo'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Branch> _getAvailableBranches(String branchType) {
    // Siempre usar Branch.sampleBranches como fuente para asegurar que sean las mismas instancias
    final allBranches = Branch.sampleBranches;
    
    if (_selectedProduct == null) return allBranches;

    if (branchType == 'from') {
      // Sedes origen: solo las que tienen stock del producto
      return allBranches.where((branch) {
        return _selectedProduct!.stockInBranch(branch.id) > 0 &&
               (_selectedToBranch == null || branch.id != _selectedToBranch!.id);
      }).toList();
    } else {
      // Sedes destino: todas excepto la sede origen
      return allBranches.where((branch) {
        return _selectedFromBranch == null || branch.id != _selectedFromBranch!.id;
      }).toList();
    }
  }

  Widget _buildQuantitySelector() {
    final maxQuantity = _selectedProduct != null && _selectedFromBranch != null
        ? _selectedProduct!.stockInBranch(_selectedFromBranch!.id)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad a Transferir',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _transferQuantity > 1
                  ? () => setState(() => _transferQuantity--)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Text(
                  '$_transferQuantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _transferQuantity < maxQuantity
                  ? () => setState(() => _transferQuantity++)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (maxQuantity > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Stock disponible: $maxQuantity',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas (Opcional)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Motivo de la transferencia...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildTransferSummary() {
    if (_selectedProduct == null || _selectedFromBranch == null || _selectedToBranch == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Transferencia:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('✅ ${_selectedProduct!.name}'),
          Text('📤 De: ${_selectedFromBranch!.name}'),
          Text('📥 A: ${_selectedToBranch!.name}'),
          Text('📦 Cantidad: $_transferQuantity ${_selectedProduct!.unit}'),
          if (_notesController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('📝 Notas: ${_notesController.text}'),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    final isValid = _selectedProduct != null &&
        _selectedFromBranch != null &&
        _selectedToBranch != null &&
        _transferQuantity > 0 &&
        !_isLoading;

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: isValid ? _validateAndCreateTransfer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppColors.primary : AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Creando...',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                'Crear Transferencia',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _validateAndCreateTransfer() async {
    if (_selectedProduct == null || _selectedFromBranch == null || _selectedToBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final availableStock = _selectedProduct!.stockInBranch(_selectedFromBranch!.id);
    if (_transferQuantity > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock insuficiente. Disponible: $availableStock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Crear la transferencia
    final transfer = Transfer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      fromBranchId: _selectedFromBranch!.id,
      fromBranchName: _selectedFromBranch!.name,
      toBranchId: _selectedToBranch!.id,
      toBranchName: _selectedToBranch!.name,
      quantity: _transferQuantity,
      transferDate: DateTime.now(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // Guardar la transferencia
    await _saveTransfer(transfer);
  }

  Future<void> _saveTransfer(Transfer transfer) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí deberías llamar a un servicio de API para guardar la transferencia
      // Por ahora simulamos el guardado
      await Future.delayed(const Duration(seconds: 1));
      
      // Actualizar el stock del producto localmente
      if (_selectedProduct != null && _selectedFromBranch != null && _selectedToBranch != null) {
        final updatedProduct = _selectedProduct!.transferStock(
          fromBranchId: _selectedFromBranch!.id,
          toBranchId: _selectedToBranch!.id,
          quantity: _transferQuantity,
        );
        
        // Actualizar en la lista
        final index = _availableProducts.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          setState(() {
            _availableProducts[index] = updatedProduct;
            _selectedProduct = updatedProduct;
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Transferencia creada exitosamente\n'
              '${transfer.productName}: ${transfer.quantity} ${_selectedProduct?.unit ?? ""} '
              'de ${transfer.fromBranchName} a ${transfer.toBranchName}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navegar de regreso después de un breve delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, transfer);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear transferencia: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}