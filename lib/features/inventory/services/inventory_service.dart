import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_models.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/services/storage_service.dart';

class InventoryService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';

  // Obtener inventario completo
  Future<InventoryResponse> getInventory() async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/inventory'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return InventoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Error al obtener inventario: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a datos mock si falla la API
      print('Error al obtener inventario de la API, usando datos mock: $e');
      return _getMockInventory();
    }
  }

  // Agregar producto al inventario
  Future<InventoryProduct> addProductToInventory(AddInventoryRequest request) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/inventory/by-product'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return InventoryProduct.fromJson(jsonData);
      } else {
        throw Exception('Error al agregar producto al inventario: ${response.statusCode}');
      }
    } catch (e) {
      // Simular respuesta exitosa con datos mock
      print('Error al agregar producto al inventario, simulando respuesta: $e');
      return _simulateAddProduct(request);
    }
  }

  // Datos mock para desarrollo y fallback
  InventoryResponse _getMockInventory() {
    return InventoryResponse(
      productos: [
        InventoryProduct(
          id: 1,
          productoId: 1,
          productoNombre: 'Leche Gloria',
          categoriaNombre: 'Lácteos',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 3)),
          cantidad: 20,
          precio: 5.0,
          stockMinimo: 5,
          total: 100.0,
          stockBajo: false,
          codigoBarras: '7750182000017',
        ),
        InventoryProduct(
          id: 2,
          productoId: 2,
          productoNombre: 'Pan Bimbo',
          categoriaNombre: 'Panadería',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 1)),
          cantidad: 12,
          precio: 2.5,
          stockMinimo: 10,
          total: 30.0,
          stockBajo: false,
          codigoBarras: '7750168000024',
        ),
        InventoryProduct(
          id: 3,
          productoId: 3,
          productoNombre: 'Arroz Costeño',
          categoriaNombre: 'Granos',
          unidadNombre: 'kilogramo',
          unidadAbreviacion: 'kg',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 5)),
          cantidad: 8,
          precio: 3.0,
          stockMinimo: 15,
          total: 24.0,
          stockBajo: true,
          codigoBarras: '7751493000123',
        ),
        InventoryProduct(
          id: 4,
          productoId: 4,
          productoNombre: 'Azúcar Rubia',
          categoriaNombre: 'Endulzantes',
          unidadNombre: 'kilogramo',
          unidadAbreviacion: 'kg',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 7)),
          cantidad: 25,
          precio: 4.5,
          stockMinimo: 10,
          total: 112.5,
          stockBajo: false,
          codigoBarras: '7750885000987',
        ),
        InventoryProduct(
          id: 5,
          productoId: 5,
          productoNombre: 'Aceite Primor',
          categoriaNombre: 'Aceites',
          unidadNombre: 'litro',
          unidadAbreviacion: 'l',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 2)),
          cantidad: 6,
          precio: 8.0,
          stockMinimo: 8,
          total: 48.0,
          stockBajo: true,
          codigoBarras: '7750243000456',
        ),
        InventoryProduct(
          id: 6,
          productoId: 6,
          productoNombre: 'Inca Kola',
          categoriaNombre: 'Bebidas',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 1)),
          cantidad: 24,
          precio: 3.5,
          stockMinimo: 10,
          total: 84.0,
          stockBajo: false,
          codigoBarras: '7750182001014',
        ),
        InventoryProduct(
          id: 7,
          productoId: 7,
          productoNombre: 'Atún Florida',
          categoriaNombre: 'Enlatados',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 4)),
          cantidad: 15,
          precio: 6.0,
          stockMinimo: 5,
          total: 90.0,
          stockBajo: false,
          codigoBarras: '7751271000789',
        ),
        InventoryProduct(
          id: 8,
          productoId: 8,
          productoNombre: 'Sal Marina',
          categoriaNombre: 'Condimentos',
          unidadNombre: 'kilogramo',
          unidadAbreviacion: 'kg',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 10)),
          cantidad: 10,
          precio: 1.5,
          stockMinimo: 3,
          total: 15.0,
          stockBajo: false,
          codigoBarras: '7750106000321',
        ),
        InventoryProduct(
          id: 9,
          productoId: 9,
          productoNombre: 'Arveja Verde',
          categoriaNombre: 'Verduras',
          unidadNombre: 'kilogramo',
          unidadAbreviacion: 'kg',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 2)),
          cantidad: 8,
          precio: 2.5,
          stockMinimo: 5,
          total: 20.0,
          stockBajo: false,
          codigoBarras: '7750320000159',
        ),
        InventoryProduct(
          id: 10,
          productoId: 10,
          productoNombre: 'Fideos Don Vittorio',
          categoriaNombre: 'Pastas',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 3)),
          cantidad: 30,
          precio: 2.8,
          stockMinimo: 10,
          total: 84.0,
          stockBajo: false,
          codigoBarras: '7750575000654',
        ),
        InventoryProduct(
          id: 11,
          productoId: 11,
          productoNombre: 'Vinagre Firme',
          categoriaNombre: 'Condimentos',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 5)),
          cantidad: 12,
          precio: 3.2,
          stockMinimo: 4,
          total: 38.4,
          stockBajo: false,
          codigoBarras: '7750410000753',
        ),
        InventoryProduct(
          id: 12,
          productoId: 12,
          productoNombre: 'Sillao Kikko',
          categoriaNombre: 'Condimentos',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'und',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 6)),
          cantidad: 8,
          precio: 4.5,
          stockMinimo: 3,
          total: 36.0,
          stockBajo: false,
          codigoBarras: '7750557000852',
        ),
      ],
      lotes: [
        InventoryBatch(
          id: 1,
          productoId: 1,
          productoNombre: 'Leche',
          unidadNombre: 'mililitro',
          unidadAbreviacion: 'ml',
          proveedor: 'Rosaura Lopez',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 3)),
          cantidad: 100,
          precio: 5.0,
          total: 500.0,
        ),
        InventoryBatch(
          id: 2,
          productoId: 2,
          productoNombre: 'Pan',
          unidadNombre: 'unidad',
          unidadAbreviacion: 'unidad',
          proveedor: 'Panadería Central',
          fechaEntrada: DateTime.now().subtract(const Duration(days: 1)),
          cantidad: 50,
          precio: 2.5,
          total: 125.0,
        ),
      ],
    );
  }

  InventoryProduct _simulateAddProduct(AddInventoryRequest request) {
    // Simular la creación de un nuevo producto en el inventario
    return InventoryProduct(
      id: DateTime.now().millisecondsSinceEpoch,
      productoId: request.productoId,
      productoNombre: 'Producto Mock ${request.productoId}',
      categoriaNombre: 'Categoría Mock',
      unidadNombre: 'unidad',
      unidadAbreviacion: 'u',
      fechaEntrada: DateTime.now(),
      cantidad: request.cantidad,
      precio: request.precio,
      stockMinimo: request.stockMinimo,
      total: request.cantidad * request.precio,
      stockBajo: request.cantidad <= request.stockMinimo,
    );
  }
}