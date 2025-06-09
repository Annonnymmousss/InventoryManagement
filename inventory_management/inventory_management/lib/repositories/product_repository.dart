
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_management/models/product.dart';

class ProductRepository {
  static const String baseUrl = 'http://localhost:8080/api/products';

  Future<List<Product>> getProducts() async {
    try {
      print('Fetching products from: $baseUrl');
      final response = await http.get(Uri.parse(baseUrl));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
   
        if (response.body == 'null' || response.body.trim().isEmpty) {
          print('Empty or null response, returning empty list');
          return [];
        }
        
        final dynamic jsonData = json.decode(response.body);

        if (jsonData == null) {
          print('JSON data is null, returning empty list');
          return [];
        }
   
        if (jsonData is! List) {
          print('Response is not a list, returning empty list');
          return [];
        }
        
        final List<dynamic> jsonList = jsonData;
        print('Successfully parsed ${jsonList.length} products');
        
        return jsonList.map((json) {
          try {
            return Product.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing product: $e');
          
            return null;
          }
        }).where((product) => product != null).cast<Product>().toList();
        
      } else if (response.statusCode == 404) {
       
        print('API endpoint not found (404), returning empty list');
        return [];
      } else {
        throw Exception('Failed to load products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
 
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception('Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      print('Creating product: ${product.name}');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body == 'null' || response.body.trim().isEmpty) {
      
          return product;
        }
        
        final dynamic jsonData = json.decode(response.body);
        if (jsonData == null) {
          return product;
        }
        
        return Product.fromJson(jsonData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create product: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating product: $e');
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      print('Updating product: ${product.name} (ID: ${product.id})');
      final response = await http.put(
        Uri.parse('$baseUrl/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body == 'null' || response.body.trim().isEmpty || response.statusCode == 204) {
         
          return product;
        }
        
        final dynamic jsonData = json.decode(response.body);
        if (jsonData == null) {
          return product;
        }
        
        return Product.fromJson(jsonData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update product: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      print('Deleting product with ID: $id');
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check if the server is running.');
      }
      throw Exception('Network error: $e');
    }
  }
}