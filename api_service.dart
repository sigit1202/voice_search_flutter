// File: lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://versibaru1.onrender.com';

  static Future<List<dynamic>> searchData(String keyword) async {
    final url = Uri.parse('$baseUrl/search?query=$keyword');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data');
    }
  }
}
