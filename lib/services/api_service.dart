import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ApiService {
  static const String baseUrl = 'https://691088177686c0e9c20ad8a5.mockapi.io';

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List) {
          print('Successfully parsed ${data.length} services');
          return data.map((json) => ServiceModel.fromJson(json)).toList();
        } else if (data is Map) {
          print('Single service object received, wrapping in list');
          return (data['services'] as List)
              .map((json) => ServiceModel.fromJson(json))
              .toList();

        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load services. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Network error: $e');
    }
  }
}