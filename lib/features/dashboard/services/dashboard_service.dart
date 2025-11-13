import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/storage_service.dart';
import '../models/product.dart';

class DashboardService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';

  Future<String?> _getAuthToken() async {
    return await StorageService.getToken();
  }

  Map<String, String> _buildHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<DashboardStats> getDashboardStats() async {
    try {
      final token = await _getAuthToken();
      print('DashboardService: Getting dashboard stats with token: ${token?.isNotEmpty == true ? "Present" : "Missing"}');
      
      // Hacer llamadas paralelas para obtener los datos
      final [productsResponse, movementsResponse] = await Future.wait([
        _getTotalProducts(token),
        _getMovementsToday(token),
      ]);

      return DashboardStats(
        totalProducts: productsResponse,
        movementsToday: movementsResponse,
      );
    } catch (e) {
      print('DashboardService: Error getting dashboard stats: $e');
      // Retornar estadísticas por defecto en caso de error
      return DashboardStats(
        totalProducts: 0,
        movementsToday: 0,
      );
    }
  }

  Future<int> _getTotalProducts(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: _buildHeaders(token: token),
      );

      print('DashboardService: Get products response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        return products.length;
      } else {
        print('DashboardService: Failed to get products - Status: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('DashboardService: Error getting total products: $e');
      return 0;
    }
  }

  Future<int> _getMovementsToday(String? token) async {
    try {
      // Intentamos obtener movimientos desde el endpoint de inventario
      final response = await http.get(
        Uri.parse('$_baseUrl/inventory'),
        headers: _buildHeaders(token: token),
      );

      print('DashboardService: Get movements response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic inventoryData = json.decode(response.body);
        
        // Verificar si es una lista o un objeto
        List<dynamic> inventory = [];
        if (inventoryData is List) {
          inventory = inventoryData;
        } else if (inventoryData is Map && inventoryData.containsKey('data')) {
          // Si es un objeto que contiene una lista en 'data'
          final data = inventoryData['data'];
          if (data is List) {
            inventory = data;
          }
        } else {
          print('DashboardService: Unexpected inventory data structure');
          return 0;
        }
        
        // Contar movimientos del día actual
        final today = DateTime.now();
        final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        
        int movementsToday = 0;
        for (final item in inventory) {
          final createdAt = item['createdAt'] ?? '';
          if (createdAt.startsWith(todayString)) {
            movementsToday++;
          }
        }
        
        return movementsToday;
      } else {
        print('DashboardService: Failed to get movements - Status: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('DashboardService: Error getting movements today: $e');
      return 0;
    }
  }

  Future<List<Product>> getRecentProducts() async {
    try {
      final token = await _getAuthToken();
      print('DashboardService: Getting recent products with token: ${token?.isNotEmpty == true ? "Present" : "Missing"}');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: _buildHeaders(token: token),
      );

      print('DashboardService: Get recent products response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        // Ordenar por ID descendente para obtener los más recientes primero
        products.sort((a, b) => b.id.compareTo(a.id));
        
        // Retornar los primeros 5 productos más recientes
        return products.take(5).toList();
      } else if (response.statusCode == 401) {
        print('DashboardService: Unauthorized - token may have expired');
        throw Exception('Token de autenticación expirado');
      } else {
        print('DashboardService: Failed to get recent products - Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('DashboardService: Error getting recent products: $e');
      return [];
    }
  }
}