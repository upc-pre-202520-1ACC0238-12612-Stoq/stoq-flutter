import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/storage_service.dart';
import '../models/combo_models.dart';

class ComboService {
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

  Future<List<Combo>> getCombos() async {
    try {
      final token = await _getAuthToken();
      print('ComboService: Getting combos with token: ${token?.isNotEmpty == true ? "Present" : "Missing"}');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/combos'),
        headers: _buildHeaders(token: token),
      );

      print('ComboService: Get combos response status: ${response.statusCode}');
      print('ComboService: Get combos response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Combo.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('ComboService: Unauthorized - token may have expired');
        throw Exception('Token de autenticación expirado');
      } else {
        print('ComboService: Failed to get combos - Status: ${response.statusCode}');
        throw Exception('Error al obtener combos: ${response.statusCode}');
      }
    } catch (e) {
      print('ComboService: Error getting combos: $e');
      // Retornar lista vacía en caso de error
      return [];
    }
  }

  Future<Combo?> createCombo(ComboRequest comboRequest) async {
    try {
      final token = await _getAuthToken();
      print('ComboService: Creating combo with token: ${token?.isNotEmpty == true ? "Present" : "Missing"}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/combos'),
        headers: _buildHeaders(token: token),
        body: json.encode(comboRequest.toJson()),
      );

      print('ComboService: Create combo response status: ${response.statusCode}');
      print('ComboService: Create combo response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Combo.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        print('ComboService: Unauthorized - token may have expired');
        throw Exception('Token de autenticación expirado');
      } else {
        print('ComboService: Failed to create combo - Status: ${response.statusCode}');
        throw Exception('Error al crear combo: ${response.statusCode}');
      }
    } catch (e) {
      print('ComboService: Error creating combo: $e');
      rethrow;
    }
  }
}