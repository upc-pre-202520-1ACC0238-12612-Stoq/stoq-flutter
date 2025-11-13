import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';
import '../../products/models/product_models.dart';
import '../../products/services/product_service.dart';

class AddInventoryModal extends StatefulWidget {
  final Function(InventoryProduct) onInventoryAdded;

  const AddInventoryModal({
    super.key,
    required this.onInventoryAdded,
  });

  @override
  State<AddInventoryModal> createState() => _AddInventoryModalState();
}

class _AddInventoryModalState extends State<AddInventoryModal> {
  final InventoryService _inventoryService = InventoryService();
  final ProductService _productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para los campos del formulario
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockMinimoController = TextEditingController();

  // Variables de estado
  List<Product> _availableProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _availableProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      _showErrorMessage('Error al cargar productos: $e');
    }
  }

  Future<void> _addToInventory() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) {
      _showErrorMessage('Por favor selecciona un producto');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = AddInventoryRequest(
        productoId: _selectedProduct!.id,
        cantidad: int.parse(_cantidadController.text),
        precio: double.parse(_precioController.text),
        stockMinimo: int.parse(_stockMinimoController.text),
      );

      final inventoryProduct = await _inventoryService.addProductToInventory(request);
      
      widget.onInventoryAdded(inventoryProduct);
      Navigator.pop(context);
      
    } catch (e) {
      _showErrorMessage('Error al agregar producto al inventario: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header del modal
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
                const Expanded(
                  child: Text(
                    'Agregar al Inventario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Para balancear el botón de cerrar
              ],
            ),
          ),
          
          // Formulario
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de producto
                    const Text(
                      'Producto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingProducts
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _availableProducts.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No hay productos disponibles',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              )
                            : DropdownButtonFormField<Product>(
                                value: _selectedProduct,
                                onChanged: (product) {
                                  setState(() {
                                    _selectedProduct = product;
                                    // Pre-llenar precio si está disponible
                                    if (product != null && _precioController.text.isEmpty) {
                                      _precioController.text = product.salePrice.toString();
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Selecciona un producto',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Debes seleccionar un producto';
                                  }
                                  return null;
                                },
                                items: _availableProducts.map((product) {
                                  return DropdownMenuItem(
                                    value: product,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          product.categoryName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Cantidad
                    const Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ej: 50',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        suffixText: _selectedProduct?.unitName ?? '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La cantidad es obligatoria';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingresa una cantidad válida';
                        }
                        if (int.parse(value) <= 0) {
                          return 'La cantidad debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Precio por unidad
                    const Text(
                      'Precio por Unidad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _precioController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: 's/. ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio es obligatorio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un precio válido';
                        }
                        if (double.parse(value) <= 0) {
                          return 'El precio debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Stock mínimo
                    const Text(
                      'Stock Mínimo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stockMinimoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ej: 10',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        suffixText: _selectedProduct?.unitName ?? '',
                        helperText: 'Se alertará cuando el stock esté por debajo de este valor',
                        helperStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El stock mínimo es obligatorio';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingresa un stock mínimo válido';
                        }
                        if (int.parse(value) < 0) {
                          return 'El stock mínimo no puede ser negativo';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Resumen si hay producto seleccionado
                    if (_selectedProduct != null && 
                        _cantidadController.text.isNotEmpty && 
                        _precioController.text.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumen',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Producto:',
                              _selectedProduct!.name,
                            ),
                            _buildSummaryRow(
                              'Cantidad:',
                              '${_cantidadController.text} ${_selectedProduct!.unitAbbreviation}',
                            ),
                            _buildSummaryRow(
                              'Precio unitario:',
                              's/. ${_precioController.text}',
                            ),
                            if (_cantidadController.text.isNotEmpty && 
                                _precioController.text.isNotEmpty &&
                                double.tryParse(_precioController.text) != null &&
                                int.tryParse(_cantidadController.text) != null)
                              _buildSummaryRow(
                                'Valor total:',
                                's/. ${(double.parse(_precioController.text) * int.parse(_cantidadController.text)).toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                    ],
                    
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addToInventory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redAccent,
                          foregroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Agregando...'),
                                ],
                              )
                            : const Text(
                                'Agregar al Inventario',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}