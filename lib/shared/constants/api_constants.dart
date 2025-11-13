class ApiConstants {
  static const String baseUrl = 'http://34.39.181.148:8080/api/v1';
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/signin';
  
  // Product endpoints
  static const String productsEndpoint = '/products';
  static const String tagsEndpoint = '/tags';
  
  // Inventory endpoints
  static const String inventoryEndpoint = '/inventory';
  static const String inventoryByProductEndpoint = '/inventory/by-product';
  
  // Combo endpoints
  static const String combosEndpoint = '/combos';
}