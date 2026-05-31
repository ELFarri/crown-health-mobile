import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  static Future<Map<String, dynamic>?> searchByBarcode(String barcode) async {
    try {
      final String targetUrl = '$_baseUrl/product/$barcode.json';
      http.Response response;
      if (kIsWeb) {
        final String proxyUrl1 = 'https://api.codetabs.com/v1/proxy/?quest=${Uri.encodeComponent(targetUrl)}';
        print('--- Web Barcode Search via Proxy 1: $proxyUrl1 ---');
        response = await http.get(Uri.parse(proxyUrl1));
        print('Proxy 1 response code: ${response.statusCode}');
        
        if (response.statusCode != 200) {
          final String proxyUrl2 = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}';
          print('--- Barcode Proxy 1 failed, trying fallback Proxy 2: $proxyUrl2 ---');
          response = await http.get(Uri.parse(proxyUrl2));
          print('Proxy 2 response code: ${response.statusCode}');
        }
      } else {
        response = await http.get(Uri.parse(targetUrl));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};
          return {
            'name': product['product_name'] ?? 'Unknown Product',
            'kcal': _parseInt(nutriments['energy-kcal_100g']),
            'protein': _parseDouble(nutriments['proteins_100g']),
            'carbs': _parseDouble(nutriments['carbohydrates_100g']),
            'fat': _parseDouble(nutriments['fat_100g']),
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
    print('--- Nutrition Search Triggered: query="$query", kIsWeb=$kIsWeb ---');
    try {
      final String targetUrl = 'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=20&lc=en';
      
      http.Response response;
      if (kIsWeb) {
        final String proxyUrl1 = 'https://api.codetabs.com/v1/proxy/?quest=${Uri.encodeComponent(targetUrl)}';
        print('Fetching via Proxy 1 (codetabs): $proxyUrl1');
        response = await http.get(Uri.parse(proxyUrl1));
        print('Proxy 1 response code: ${response.statusCode}');
        
        if (response.statusCode != 200) {
          final String proxyUrl2 = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}';
          print('Proxy 1 failed, trying fallback Proxy 2 (allorigins): $proxyUrl2');
          response = await http.get(Uri.parse(proxyUrl2));
          print('Proxy 2 response code: ${response.statusCode}');
        }
      } else {
        print('Fetching directly: $targetUrl');
        response = await http.get(Uri.parse(targetUrl));
      }

      print('Response body length: ${response.body.length}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List products = data['products'] ?? [];
        return products.map((p) {
          final nutriments = p['nutriments'] ?? {};
          return {
            'name': p['product_name'] ?? 'Unknown',
            'kcal': _parseInt(nutriments['energy-kcal_100g']),
            'protein': _parseDouble(nutriments['proteins_100g']),
            'carbs': _parseDouble(nutriments['carbohydrates_100g']),
            'fat': _parseDouble(nutriments['fat_100g']),
          };
        }).toList();
      }
    } catch (e) {
      print('Name Search Error: $e');
    }
    return [];
  }
}
