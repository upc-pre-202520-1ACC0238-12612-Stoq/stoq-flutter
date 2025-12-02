import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/barcode_scan_result.dart';

class BarcodeScanService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.all],
  );

  // Procesa la imagen y busca códigos de barras reales
  Future<BarcodeScanResult?> processBarcodeScan(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);

      // Intentar escanear código de barras real
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final barcodeValue = barcode.rawValue ?? barcode.displayValue ?? '';

        if (barcodeValue.isNotEmpty) {
          // Buscar producto por código de barras
          return _getProductFromBarcode(barcodeValue, barcode.format);
        }
      }

      // Si no hay código de barras, usar reconocimiento de imagen como fallback
      return await _processWithImageLabeling(imageFile);
    } catch (e) {
      throw Exception('Error al procesar imagen: $e');
    }
  }

  // Fallback: usar ML Kit Image Labeling si no hay código de barras
  Future<BarcodeScanResult?> _processWithImageLabeling(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final options = ImageLabelerOptions(confidenceThreshold: 0.5);
      final labeler = ImageLabeler(options: options);
      final labels = await labeler.processImage(inputImage);
      await labeler.close();

      if (labels.isEmpty) {
        return null;
      }

      final detectedLabel = labels.first.label;
      return _getProductFromLabel(detectedLabel);
    } catch (e) {
      return null;
    }
  }

  // Buscar producto por código de barras real
  // En producción, esto consultaría una API o base de datos
  BarcodeScanResult _getProductFromBarcode(String barcodeValue, BarcodeFormat format) {
    // Base de datos mock de productos con códigos de barras
    final productDatabase = {
      // Códigos EAN-13 de ejemplo
      '7750182000017': BarcodeScanResult(
        productId: 1,
        productName: 'Leche Gloria',
        unitPrice: 5.00,
        unit: 'und',
        availableStock: 100,
        barcode: '7750182000017',
      ),
      '7750182001014': BarcodeScanResult(
        productId: 2,
        productName: 'Gaseosa Inca Kola',
        unitPrice: 3.50,
        unit: 'und',
        availableStock: 50,
        barcode: '7750182001014',
      ),
      '7751493000123': BarcodeScanResult(
        productId: 3,
        productName: 'Arroz Costeño',
        unitPrice: 3.00,
        unit: 'kg',
        availableStock: 75,
        barcode: '7751493000123',
      ),
      '7750243000456': BarcodeScanResult(
        productId: 4,
        productName: 'Aceite Primor',
        unitPrice: 8.00,
        unit: 'l',
        availableStock: 30,
        barcode: '7750243000456',
      ),
      '7751271000789': BarcodeScanResult(
        productId: 5,
        productName: 'Atún Florida',
        unitPrice: 6.00,
        unit: 'und',
        availableStock: 40,
        barcode: '7751271000789',
      ),
      '7750106000321': BarcodeScanResult(
        productId: 6,
        productName: 'Sal Marina',
        unitPrice: 1.50,
        unit: 'kg',
        availableStock: 60,
        barcode: '7750106000321',
      ),
      '7750575000654': BarcodeScanResult(
        productId: 7,
        productName: 'Fideos Don Vittorio',
        unitPrice: 2.80,
        unit: 'und',
        availableStock: 80,
        barcode: '7750575000654',
      ),
      '7750885000987': BarcodeScanResult(
        productId: 8,
        productName: 'Azúcar Rubia',
        unitPrice: 4.50,
        unit: 'kg',
        availableStock: 45,
        barcode: '7750885000987',
      ),
    };

    // Buscar producto por código exacto
    if (productDatabase.containsKey(barcodeValue)) {
      return productDatabase[barcodeValue]!;
    }

    // Si no está en la base de datos, retornar producto genérico con el código
    return BarcodeScanResult(
      productId: 0,
      productName: 'Producto: $barcodeValue',
      unitPrice: 0.00,
      unit: 'und',
      availableStock: 0,
      barcode: barcodeValue,
    );
  }

  // Mapeo de etiquetas de imagen a productos (fallback)
  BarcodeScanResult _getProductFromLabel(String label) {
    final mockProducts = {
      'Food': BarcodeScanResult(
        productId: 1,
        productName: 'Producto Alimenticio',
        unitPrice: 5.00,
        unit: 'und',
        availableStock: 100,
      ),
      'Bottle': BarcodeScanResult(
        productId: 2,
        productName: 'Gaseosa',
        unitPrice: 3.50,
        unit: 'und',
        availableStock: 50,
      ),
      'Drink': BarcodeScanResult(
        productId: 3,
        productName: 'Bebida',
        unitPrice: 4.00,
        unit: 'und',
        availableStock: 75,
      ),
      'Vegetable': BarcodeScanResult(
        productId: 4,
        productName: 'Arveja',
        unitPrice: 2.50,
        unit: 'kg',
        availableStock: 30,
      ),
      'Rice': BarcodeScanResult(
        productId: 5,
        productName: 'Arroz',
        unitPrice: 3.00,
        unit: 'kg',
        availableStock: 100,
      ),
      'Fish': BarcodeScanResult(
        productId: 6,
        productName: 'Atún',
        unitPrice: 6.00,
        unit: 'und',
        availableStock: 40,
      ),
      'Seasoning': BarcodeScanResult(
        productId: 7,
        productName: 'Sal',
        unitPrice: 1.50,
        unit: 'kg',
        availableStock: 60,
      ),
      'Sauce': BarcodeScanResult(
        productId: 8,
        productName: 'Sillao',
        unitPrice: 4.50,
        unit: 'und',
        availableStock: 35,
      ),
      'Pasta': BarcodeScanResult(
        productId: 9,
        productName: 'Tallarín',
        unitPrice: 2.80,
        unit: 'und',
        availableStock: 80,
      ),
      'Liquid': BarcodeScanResult(
        productId: 10,
        productName: 'Vinagre',
        unitPrice: 3.20,
        unit: 'und',
        availableStock: 45,
      ),
    };

    for (final entry in mockProducts.entries) {
      if (label.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(label.toLowerCase())) {
        return entry.value;
      }
    }

    return BarcodeScanResult(
      productId: 99,
      productName: label,
      unitPrice: 10.00,
      unit: 'und',
      availableStock: 20,
    );
  }

  // Liberar recursos
  void dispose() {
    _barcodeScanner.close();
  }
}
