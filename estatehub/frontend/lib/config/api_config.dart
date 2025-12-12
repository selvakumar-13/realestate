class ApiConfig {
  // Backend URL - change if needed
  static const String baseUrl = 'http://localhost:8000';
  static const String apiUrl = '$baseUrl/api/v1';
  
  // Auth endpoints
  static const String loginUrl = '$apiUrl/auth/login';
  static const String registerUrl = '$apiUrl/auth/register';
  
  // Property endpoints
  static const String propertiesUrl = '$apiUrl/properties';
  
  // Helper method to get property by ID
  static String propertyDetailUrl(String id) => '$propertiesUrl/$id';
}