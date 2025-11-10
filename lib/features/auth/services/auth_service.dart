import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';
  static const String _loginEndpoint = '/authentication/sign-in';
  
  // Variables en memoria (temporal, sin persistencia)
  static LoginResponse? _currentUser;
  static String? _currentToken;

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
        
        // Guardar en memoria
        _currentUser = loginResponse;
        _currentToken = loginResponse.token;
        
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
    return _currentToken;
  }

  Future<LoginResponse?> getUserData() async {
    return _currentUser;
  }

  Future<bool> isLoggedIn() async {
    return _currentToken != null && _currentToken!.isNotEmpty;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _currentToken = null;
  }
}