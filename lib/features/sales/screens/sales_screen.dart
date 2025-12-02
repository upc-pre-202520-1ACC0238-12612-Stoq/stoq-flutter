import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../inventory/services/inventory_service.dart';
import '../../inventory/models/inventory_models.dart';
import '../services/sales_service.dart';
import '../models/sale_request_model.dart';
import '../models/stock_check_model.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _salesService = SalesService();
  final _inventoryService = InventoryService();
  final _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  // Estado del formulario
  bool _isScanning = false;
  InventoryProduct? _selectedProduct;
  StockCheck? _stockCheck;
  List<InventoryProduct> _availableProducts = [];
  bool _isLoading = false;
  bool _isLoadingProducts = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  // Cargar productos disponibles desde inventario
  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final inventory = await _inventoryService.getInventory();
      setState(() {
        _availableProducts = inventory.productos;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
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

  // Filtrar productos por búsqueda
  List<InventoryProduct> get _filteredProducts {
    if (_searchQuery.isEmpty) return _availableProducts;

    return _availableProducts.where((product) =>
      product.productoNombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      product.categoriaNombre.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // Verificar stock del producto seleccionado
  Future<void> _checkProductStock(int productId) async {
    try {
      final stockCheck = await _salesService.checkProductStock(productId);
      setState(() {
        _stockCheck = stockCheck;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar stock: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Seleccionar producto
  void _selectProduct(InventoryProduct product) {
    setState(() {
      _selectedProduct = product;
      _stockCheck = null;
      _quantityController.clear();
    });
    _checkProductStock(product.productoId);
  }

  // Calcular total de la venta
  double get _totalAmount {
    if (_selectedProduct == null || _quantityController.text.isEmpty) return 0.0;

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = _selectedProduct!.precio;
    return quantity * unitPrice;
  }

  // Validar stock disponible
  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una cantidad';
    }

    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Ingrese una cantidad válida';
    }

    if (_stockCheck != null && !_stockCheck!.canSellQuantity(quantity)) {
      return 'Stock insuficiente. Disponible: ${_stockCheck!.formattedStock}';
    }

    return null;
  }

  // Realizar venta
  Future<void> _performSale() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final saleRequest = SaleRequest(
        productId: _selectedProduct!.productoId,
        quantity: int.parse(_quantityController.text),
        unitPrice: _selectedProduct!.precio,
        customerName: _customerNameController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      );

      final saleResponse = await _salesService.createSale(saleRequest);

      if (mounted) {
        // Mostrar éxito y redirigir a detalles
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venta realizada con éxito! ID: ${saleResponse.id}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Limpiar formulario
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar venta: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Limpiar formulario
  void _clearForm() {
    _formKey.currentState?.reset();
    _customerNameController.clear();
    _quantityController.clear();
    _notesController.clear();
    setState(() {
      _selectedProduct = null;
      _stockCheck = null;
    });
  }

  // Escanear código de barras
  Future<void> _scanBarcode() async {
    if (_availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Espere a que carguen los productos'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      // Abrir cámara para capturar imagen del código de barras
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image == null) return; // Usuario canceló

      setState(() {
        _isScanning = true;
      });

      // Procesar imagen con ML Kit Barcode Scanner
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se detectó ningún código de barras'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Obtener el código de barras detectado
      final barcode = barcodes.first;
      final barcodeValue = barcode.rawValue ?? barcode.displayValue ?? '';

      if (barcodeValue.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código de barras vacío'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Buscar producto por código de barras en el inventario
      final matchedProduct = _availableProducts.firstWhere(
        (p) => p.codigoBarras == barcodeValue,
        orElse: () => InventoryProduct(
          id: -1,
          productoId: -1,
          productoNombre: '',
          categoriaNombre: '',
          unidadNombre: '',
          unidadAbreviacion: '',
          fechaEntrada: DateTime.now(),
          cantidad: 0,
          precio: 0,
          stockMinimo: 0,
          total: 0,
          stockBajo: false,
        ),
      );

      if (mounted) {
        if (matchedProduct.id != -1) {
          // Producto encontrado
          _selectProduct(matchedProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${matchedProduct.productoNombre} ($barcodeValue)'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Producto no encontrado
          _showProductNotFoundDialog(barcodeValue);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // Mostrar diálogo cuando el producto escaneado no está en inventario
  void _showProductNotFoundDialog(String barcodeValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(child: Text('Producto no encontrado')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Código escaneado:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText(
              barcodeValue,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Este código de barras no está registrado en tu inventario.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // El usuario puede seleccionar manualmente de la lista
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Seleccionar manual', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Realizar Venta',
        showBackButton: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingText: 'Procesando venta...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de Producto
                _buildProductSelection(),
                const SizedBox(height: AppSizes.paddingLarge),

                // Información del producto seleccionado
                if (_selectedProduct != null) ...[
                  _buildSelectedProductInfo(),
                  const SizedBox(height: AppSizes.paddingLarge),
                ],

                // Formulario de venta
                if (_selectedProduct != null) ...[
                  _buildSaleForm(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Resumen y botón de venta
                  _buildSaleSummary(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Seleccionar Producto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              // Botón escanear
              ElevatedButton.icon(
                onPressed: _isScanning || _isLoadingProducts ? null : _scanBarcode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                icon: _isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.qr_code_scanner, size: 18),
                label: Text(_isScanning ? 'Escaneando...' : 'Escanear'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Campo de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Lista de productos
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: _isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isSelected = _selectedProduct?.id == product.id;

                      return ListTile(
                        title: Text(product.productoNombre),
                        subtitle: Text(
                          '${product.categoriaNombre} - Stock: ${product.cantidad} ${product.unidadAbreviacion}',
                        ),
                        trailing: Text(
                          'S/. ${product.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.primary10,
                        onTap: () => _selectProduct(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedProductInfo() {
    if (_stockCheck == null) {
      return const CustomCard(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                'Producto Seleccionado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          Text(
            _selectedProduct!.productoNombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Precio unitario: ${_stockCheck!.formattedPrice}'),
              Text(
                'Stock disponible: ${_stockCheck!.formattedStock}',
                style: TextStyle(
                  color: _stockCheck!.hasStock ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleForm() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles de la Venta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Cliente
          TextFormField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Cliente',
              hintText: 'Ingrese el nombre del cliente',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingrese el nombre del cliente';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Cantidad
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              hintText: _stockCheck != null
                ? 'Max: ${_stockCheck!.availableStock}'
                : 'Ingrese la cantidad',
              prefixIcon: const Icon(Icons.inventory),
              border: const OutlineInputBorder(),
              suffixText: _selectedProduct?.unidadAbreviacion ?? 'unidad',
            ),
            keyboardType: TextInputType.number,
            validator: _validateQuantity,
            onChanged: (value) {
              setState(() {}); // Para actualizar el total
            },
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Notas (opcional)
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              hintText: 'Agregar notas adicionales...',
              prefixIcon: Icon(Icons.note),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSaleSummary() {
    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a Pagar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'S/. ${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    ),
                  ),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: CustomButton(
                  text: 'Realizar Venta',
                  onPressed: _performSale,
                  backgroundColor: AppColors.success,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}