import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class PropertyService {
  static final PropertyService _instance = PropertyService._internal();
  factory PropertyService() => _instance;
  PropertyService._internal();

  final _authService = AuthService();

  // ============================================================================
  // GET ALL PROPERTIES
  // ============================================================================
  Future<Map<String, dynamic>> getAllProperties({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.propertiesUrl}/?skip=$skip&limit=$limit'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        // Backend returns {total, page, page_size, results: [...]}
        List<Property> properties = [];
        
        if (data is Map && data.containsKey('results')) {
          final List<dynamic> results = data['results'];
          properties = results.map((json) => Property.fromJson(json)).toList();
        }
        
        print('✅ Loaded ${properties.length} properties (Total: ${data['total']})');
        
        return {
          'success': true,
          'properties': properties,
        };
      } else {
        print('❌ Failed to fetch properties: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to fetch properties',
        };
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ============================================================================
  // GET FEATURED PROPERTIES
  // ============================================================================
  Future<Map<String, dynamic>> getFeaturedProperties() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.propertiesUrl}/?skip=0&limit=10'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        // Backend returns {total, page, page_size, results: [...]}
        List<Property> allProperties = [];
        
        if (data is Map && data.containsKey('results')) {
          final List<dynamic> results = data['results'];
          allProperties = results.map((json) => Property.fromJson(json)).toList();
        }
        
        // Filter featured properties
        final featured = allProperties.where((p) => p.featured).toList();
        
        // If no featured, take first 3
        final featuredProperties = featured.isNotEmpty 
            ? featured.take(3).toList()
            : allProperties.take(3).toList();
        
        print('✅ Loaded ${featuredProperties.length} featured properties');
        
        return {
          'success': true,
          'properties': featuredProperties,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch featured properties',
        };
      }
    } catch (e) {
      print('❌ Error fetching featured properties: $e');
      return {
        'success': false,
        'message': 'Network error.',
      };
    }
  }

  // ============================================================================
  // SEARCH PROPERTIES
  // ============================================================================
  Future<Map<String, dynamic>> searchProperties({
    String? query,
    String? propertyType,
    String? purpose,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      
      if (query != null && query.isNotEmpty) {
        queryParams['search'] = query;
      }
      if (propertyType != null && propertyType.isNotEmpty) {
        queryParams['property_type'] = propertyType;
      }
      if (purpose != null && purpose.isNotEmpty) {
        queryParams['purpose'] = purpose;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (bedrooms != null) {
        queryParams['bedrooms'] = bedrooms.toString();
      }

      final uri = Uri.parse('${ApiConfig.propertiesUrl}/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<Property> properties = [];
        
        if (data is Map && data.containsKey('results')) {
          final List<dynamic> results = data['results'];
          properties = results.map((json) => Property.fromJson(json)).toList();
        }
        
        return {
          'success': true,
          'properties': properties,
        };
      } else {
        return {
          'success': false,
          'message': 'Search failed',
        };
      }
    } catch (e) {
      print('❌ Error searching properties: $e');
      return {
        'success': false,
        'message': 'Search error.',
      };
    }
  }

  // ============================================================================
  // GET PROPERTY BY ID
  // ============================================================================
  Future<Map<String, dynamic>> getPropertyById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.propertyDetailUrl(id)),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final property = Property.fromJson(data);
        
        return {
          'success': true,
          'property': property,
        };
      } else {
        return {
          'success': false,
          'message': 'Property not found',
        };
      }
    } catch (e) {
      print('❌ Error fetching property: $e');
      return {
        'success': false,
        'message': 'Network error.',
      };
    }
  }
}