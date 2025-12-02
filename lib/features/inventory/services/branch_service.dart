import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/branch_model.dart';
import '../../../shared/services/storage_service.dart';

class BranchService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';

  // Obtener todas las sucursales
  Future<List<Branch>> getBranches({String? type}) async {
    try {
      final token = await StorageService.getToken();
      var url = Uri.parse('$_baseUrl/branches');
      if (type != null && type.isNotEmpty) {
        url = Uri.parse('$_baseUrl/branches?type=$type');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener sucursales: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a datos mock si falla la API
      print('Error al obtener sucursales de la API, usando datos mock: $e');
      return Branch.sampleBranches;
    }
  }

  // Obtener sucursal por ID
  Future<Branch?> getBranchById(int id) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/branches/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Branch.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener sucursal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener sucursal: $e');
      return null;
    }
  }

  // Crear nueva sucursal
  Future<Branch?> createBranch({
    required String name,
    required String type,
    required String address,
    required double latitude,
    required double longitude,
    int stockTotal = 0,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/branches'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'type': type,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'stockTotal': stockTotal,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Branch.fromJson(jsonData);
      } else {
        throw Exception('Error al crear sucursal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al crear sucursal: $e');
      return null;
    }
  }

  // Actualizar sucursal
  Future<Branch?> updateBranch({
    required int id,
    String? name,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (address != null) body['address'] = address;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await http.put(
        Uri.parse('$_baseUrl/branches/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Branch.fromJson(jsonData);
      } else {
        throw Exception('Error al actualizar sucursal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar sucursal: $e');
      return null;
    }
  }

  // Actualizar stock de sucursal
  Future<bool> updateBranchStock(int branchId, int stockTotal) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/branches/$branchId/stock'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(stockTotal),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar stock de sucursal: $e');
      return false;
    }
  }

  // Eliminar sucursal
  Future<bool> deleteBranch(int id) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/branches/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar sucursal: $e');
      return false;
    }
  }
}

