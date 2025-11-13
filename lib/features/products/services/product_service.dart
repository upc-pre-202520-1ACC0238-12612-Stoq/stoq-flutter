import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_models.dart';
import '../../../shared/services/storage_service.dart';

class ProductService {
  static const String _baseUrl = 'http://34.39.181.148:8080/api/v1';
  
  // Mock data para desarrollo
  static final List<Tag> _mockTags = [
    Tag(id: 1, name: 'Orgánico'),
    Tag(id: 2, name: 'Vegano'),
    Tag(id: 3, name: 'Sin Gluten'),
    Tag(id: 4, name: 'Premium'),
    Tag(id: 5, name: 'Importado'),
    Tag(id: 6, name: 'Local'),
  ];

  static final List<Product> _mockProducts = [
    Product(
      id: 1,
      name: 'Galleta',
      description: 'Galleta golosina premium',
      purchasePrice: 2.50,
      salePrice: 5.00,
      internalNotes: 'Producto popular',
      categoryId: 1,
      categoryName: 'Golosinas',
      unitId: 1,
      unitName: 'Unidad',
      unitAbbreviation: 'und',
      tags: [_mockTags[3], _mockTags[5]], // Premium, Local
    ),
    Product(
      id: 2,
      name: 'Chocolate Orgánico',
      description: 'Chocolate 70% cacao orgánico',
      purchasePrice: 8.00,
      salePrice: 15.00,
      internalNotes: 'Alta rotación',
      categoryId: 1,
      categoryName: 'Golosinas',
      unitId: 1,
      unitName: 'Unidad',
      unitAbbreviation: 'und',
      tags: [_mockTags[0], _mockTags[3]], // Orgánico, Premium
    ),
  ];

  // Obtener tags disponibles
  Future<List<Tag>> getTags() async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/tags'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Tag.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener tags: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a datos mock si falla la API
      print('Error al obtener tags de la API, usando datos mock: $e');
      return _mockTags;
    }
  }

  // Obtener productos
  Future<List<Product>> getProducts() async {
    try {
      final token = await StorageService.getToken();
      print('ProductService - Token obtenido: ${token != null ? "Sí (${token.length} caracteres)" : "No"}');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('ProductService - Respuesta de productos: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a datos mock si falla la API
      print('Error al obtener productos de la API, usando datos mock: $e');
      return _mockProducts;
    }
  }

  // Crear producto
  Future<Product> createProduct(ProductRequest productRequest) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productRequest.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('Error al crear producto: ${response.statusCode}');
      }
    } catch (e) {
      // Simular creación con mock data
      print('Error al crear producto en la API, simulando creación: $e');
      
      // Crear un producto mock con los datos proporcionados
      final newProduct = Product(
        id: _mockProducts.length + 1,
        name: productRequest.name,
        description: productRequest.description,
        purchasePrice: productRequest.purchasePrice,
        salePrice: productRequest.salePrice,
        internalNotes: productRequest.internalNotes,
        categoryId: productRequest.categoryId,
        categoryName: 'Categoría Mock',
        unitId: productRequest.unitId,
        unitName: 'Unidad',
        unitAbbreviation: 'und',
        tags: productRequest.tagIds
            .map((tagId) => _mockTags.firstWhere(
                  (tag) => tag.id == tagId,
                  orElse: () => Tag(id: tagId, name: 'Tag $tagId'),
                ))
            .toList(),
      );

      // Agregar a la lista mock
      _mockProducts.add(newProduct);
      return newProduct;
    }
  }

  // Buscar productos
  Future<List<Product>> searchProducts(String query) async {
    final allProducts = await getProducts();
    
    if (query.isEmpty) return allProducts;
    
    return allProducts.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.description.toLowerCase().contains(query.toLowerCase()) ||
        product.tags.any((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
}