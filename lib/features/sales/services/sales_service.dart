import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sale_request_model.dart';
import '../models/sale_response_model.dart';
import '../models/stock_check_model.dart';
import '../../../shared/services/storage_service.dart';

class SalesService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';

  // POST /api/v1/sales - Realizar venta
  Future<SaleResponse> createSale(SaleRequest request) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/sales'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SaleResponse.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        throw Exception('Datos de venta inválidos');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Inicie sesión nuevamente');
      } else if (response.statusCode == 409) {
        throw Exception('Stock insuficiente para esta venta');
      } else {
        throw Exception('Error al crear venta: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Error de conexión - Verifique su internet');
      }
      throw Exception('Error al crear venta: $e');
    }
  }

  // GET /api/v1/sales/:id - Obtener venta por ID
  Future<SaleResponse> getSaleById(String saleId) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/sales/$saleId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SaleResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Venta no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Inicie sesión nuevamente');
      } else {
        throw Exception('Error al obtener venta: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Error de conexión - Verifique su internet');
      }
      throw Exception('Error al obtener venta: $e');
    }
  }

  // GET /api/v1/sales/check-stock/:productId - Verificar stock disponible
  Future<StockCheck> checkProductStock(int productId) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/sales/check-stock/$productId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return StockCheck.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Producto no encontrado');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Inicie sesión nuevamente');
      } else {
        throw Exception('Error al verificar stock: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        // Fallback a datos mock si no hay conexión
        return _getMockStockCheck(productId);
      }
      throw Exception('Error al verificar stock: $e');
    }
  }

  // Datos mock para fallback cuando no hay conexión
  StockCheck _getMockStockCheck(int productId) {
    return StockCheck(
      productId: productId,
      productName: 'Producto Demo $productId',
      availableStock: 50,
      unitPrice: 10.0,
      unit: 'unidad',
      hasStock: true,
      lastUpdated: DateTime.now(),
    );
  }
}