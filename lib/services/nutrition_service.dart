import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  static Future<Map<String, dynamic>?> searchByBarcode(String barcode) async {
    try {
      final String targetUrl = '$_baseUrl/product/$barcode.json';
      final String url = kIsWeb ? 'https://corsproxy.io/?${Uri.encodeComponent(targetUrl)}' : targetUrl;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          return {
            'name': product['product_name'] ?? 'Unknown Product',
            'kcal': (product['nutriments']['energy-kcal_100g'] ?? 0).toInt(),
            'protein': (product['nutriments']['proteins_100g'] ?? 0).toDouble(),
            'carbs': (product['nutriments']['carbohydrates_100g'] ?? 0).toDouble(),
            'fat': (product['nutriments']['fat_100g'] ?? 0).toDouble(),
            'brand': product['brands'] ?? '',
          };
        }
      }
    } catch (e) {
      print('Barcode Search Error: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> searchByName(String query) async {
    try {
      final String targetUrl = 'https://en.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=20&lc=en';
      final String url = kIsWeb ? 'https://corsproxy.io/?${Uri.encodeComponent(targetUrl)}' : targetUrl;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List products = data['products'] ?? [];
        return products.map((p) => {
          'name': p['product_name'] ?? 'Unknown',
          'kcal': (p['nutriments']['energy-kcal_100g'] ?? 0).toInt(),
          'protein': (p['nutriments']['proteins_100g'] ?? 0).toDouble(),
          'carbs': (p['nutriments']['carbohydrates_100g'] ?? 0).toDouble(),
          'fat': (p['nutriments']['fat_100g'] ?? 0).toDouble(),
        }).toList();
      }
    } catch (e) {
      print('Name Search Error: $e');
    }
    return [];
  }
}
