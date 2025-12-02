import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../sales/services/sales_service.dart';
import '../../sales/models/sale_request_model.dart';
import '../services/barcode_scan_service.dart';
import '../models/barcode_scan_result.dart';

class BarcodeOrderScreen extends StatefulWidget {
  const BarcodeOrderScreen({super.key});

  @override
  State<BarcodeOrderScreen> createState() => _BarcodeOrderScreenState();
}

class _BarcodeOrderScreenState extends State<BarcodeOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeScanService = BarcodeScanService();
  final _salesService = SalesService();

  // Estado del pedido
  BarcodeScanResult? _scannedProduct;
  int _quantity = 0;
  bool _isScanning = false;
  bool _isProcessingSale = false;
  File? _lastScannedImage;

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Escanear código de barras (simula captura de imagen)
  Future<void> _scanBarcode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Simular captura de imagen con imágenes de prueba
      final testImages = [
        'assets/images/aceite.jpg',
        'assets/images/gaseosa.jpg',
        'assets/images/leche.jpg',
        'assets/images/arveja.png',
        'assets/images/arroz.png',
        'assets/images/atun.png',
        'assets/images/sal.png',
        'assets/images/siyao.png',
        'assets/images/tallarin.png',
        'assets/images/vinagre.png',
      ];

      final random = Random();
      final path = testImages[random.nextInt(testImages.length)];
      final byteData = await rootBundle.load(path);
      final tempFile = File('${(await getTemporaryDirectory()).path}/barcode_scan.png');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Procesar imagen
      final result = await _barcodeScanService.processBarcodeScan(tempFile);

      if (result != null) {
        setState(() {
          _lastScannedImage = tempFile;

          // Si es el mismo producto, incrementar cantidad
          if (_scannedProduct != null && _scannedProduct!.productId == result.productId) {
            _quantity++;
          } else {
            // Nuevo producto detectado
            if (_scannedProduct != null && _quantity > 0) {
              // Preguntar si desea reemplazar el producto actual
              _showReplaceProductDialog(result);
              return;
            }
            _scannedProduct = result;
            _quantity = 1;
          }
        });

        _showScanSuccessSnackbar();
      } else {
        _showErrorSnackbar('No se pudo detectar el producto');
      }
    } catch (e) {
      _showErrorSnackbar('Error al escanear: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _showReplaceProductDialog(BarcodeScanResult newProduct) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto diferente detectado'),
        content: Text(
          'El producto escaneado (${newProduct.productName}) es diferente al actual '
          '(${_scannedProduct!.productName}). ¿Desea reemplazarlo?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scannedProduct = newProduct;
                _quantity = 1;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Reemplazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showScanSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_scannedProduct!.productName} - Cantidad: $_quantity',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // Calcular total
  double get _totalAmount {
    if (_scannedProduct == null || _quantity == 0) return 0.0;
    return _scannedProduct!.unitPrice * _quantity;
  }

  // Validar stock
  bool get _hasEnoughStock {
    if (_scannedProduct == null) return true;
    return _quantity <= _scannedProduct!.availableStock;
  }

  // Ajustar cantidad manualmente
  void _incrementQuantity() {
    if (_scannedProduct != null && _quantity < _scannedProduct!.availableStock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Finalizar pedido
  Future<void> _finalizeSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scannedProduct == null || _quantity == 0) {
      _showErrorSnackbar('Escanee al menos un producto');
      return;
    }
    if (!_hasEnoughStock) {
      _showErrorSnackbar('Stock insuficiente');
      return;
    }

    setState(() {
      _isProcessingSale = true;
    });

    try {
      final saleRequest = SaleRequest(
        productId: _scannedProduct!.productId,
        quantity: _quantity,
        unitPrice: _scannedProduct!.unitPrice,
        customerName: _customerNameController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final saleResponse = await _salesService.createSale(saleRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venta realizada con éxito! ID: ${saleResponse.id}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Limpiar y volver
        _clearOrder();
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackbar('Error al realizar venta: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingSale = false;
        });
      }
    }
  }

  void _clearOrder() {
    _formKey.currentState?.reset();
    _customerNameController.clear();
    _notesController.clear();
    setState(() {
      _scannedProduct = null;
      _quantity = 0;
      _lastScannedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Escanear Pedido',
        showBackButton: true,
      ),
      body: LoadingOverlay(
        isLoading: _isProcessingSale,
        loadingText: 'Procesando venta...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Área de escaneo
                _buildScanArea(),
                const SizedBox(height: AppSizes.paddingLarge),

                // Producto escaneado
                if (_scannedProduct != null) ...[
                  _buildScannedProductCard(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Formulario de cliente
                  _buildCustomerForm(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Resumen y botones
                  _buildOrderSummary(),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _scanBarcode,
        backgroundColor: _isScanning ? Colors.grey : AppColors.primary,
        icon: _isScanning
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: Text(
          _isScanning ? 'Escaneando...' : 'Escanear',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildScanArea() {
    return CustomCard(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: _scannedProduct != null ? AppColors.success : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: _lastScannedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium - 2),
                    child: Image.file(_lastScannedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Presione el botón para escanear',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
          if (_scannedProduct != null) ...[
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Escaneos realizados: $_quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScannedProductCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 24),
              const SizedBox(width: AppSizes.paddingSmall),
              const Text(
                'Producto Detectado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          Text(
            _scannedProduct!.productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Precio: S/. ${_scannedProduct!.unitPrice.toStringAsFixed(2)}'),
              Text(
                'Stock: ${_scannedProduct!.availableStock} ${_scannedProduct!.unit}',
                style: TextStyle(
                  color: _hasEnoughStock ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Control de cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _decrementQuantity,
                icon: const Icon(Icons.remove_circle),
                color: AppColors.primary,
                iconSize: 36,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _incrementQuantity,
                icon: const Icon(Icons.add_circle),
                color: AppColors.primary,
                iconSize: 36,
              ),
            ],
          ),

          if (!_hasEnoughStock) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Stock insuficiente',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerForm() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos del Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

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

  Widget _buildOrderSummary() {
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearOrder,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasEnoughStock ? () => _finalizeSale() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'Finalizar Venta',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
