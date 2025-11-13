import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../../../shared/services/storage_service.dart';

class AuthService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';
  static const String _loginEndpoint = '/authentication/sign-in';

  Future<LoginResponse?> signIn(LoginRequest loginRequest) async {
    try {
      final url = Uri.parse('$_baseUrl$_loginEndpoint');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);
        
        // Guardar token y datos del usuario de forma persistente
        await StorageService.saveToken(loginResponse.token);
        await StorageService.saveUserData(jsonEncode(loginResponse.toJson()));
        
        return loginResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else if (response.statusCode == 500) {
        throw Exception('Error del servidor. Intente más tarde');
      } else {
        throw Exception('Error al iniciar sesión (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<String?> getToken() async {
    return await StorageService.getToken();
  }

  Future<LoginResponse?> getUserData() async {
    final userData = await StorageService.getUserData();
    if (userData != null) {
      try {
        final userJson = jsonDecode(userData);
        return LoginResponse.fromJson(userJson);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> signOut() async {
    await StorageService.clearAll();
  }
}