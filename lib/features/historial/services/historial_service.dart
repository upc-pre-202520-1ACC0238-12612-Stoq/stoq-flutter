import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/storage_service.dart';
import '../models/category_report.dart';

class HistorialService {
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

  Future<List<CategoryReport>> getCategoryReports() async {
    try {
      final token = await _getAuthToken();
      print('HistorialService: Getting reports with token: ${token?.isNotEmpty == true ? "Present" : "Missing"}');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/reports'),
        headers: _buildHeaders(token: token),
      );

      print('HistorialService: Get reports response status: ${response.statusCode}');
      print('HistorialService: Get reports response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> categoryReportsJson = responseData['categoryReports'] ?? [];
        
        final reports = categoryReportsJson
            .map((reportJson) => CategoryReport.fromJson(reportJson))
            .toList();
            
        // Ordenar por fecha descendente (más recientes primero)
        reports.sort((a, b) => b.fechaConsulta.compareTo(a.fechaConsulta));
        
        return reports;
      } else if (response.statusCode == 401) {
        print('HistorialService: Unauthorized - token may have expired');
        throw Exception('Token de autenticación expirado');
      } else {
        print('HistorialService: Failed to get reports - Status: ${response.statusCode}');
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } catch (e) {
      print('HistorialService: Error getting reports: $e');
      // Retornar lista vacía en caso de error
      return [];
    }
  }
}