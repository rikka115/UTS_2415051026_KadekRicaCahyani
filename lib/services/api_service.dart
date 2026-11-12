import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _quoteEndpoint = 'https://api.adviceslip.com/advice';

  /// Melakukan GET request ke public REST API
  Future<Map<String, dynamic>> fetchDailyQuote() async {
    try {
      final response = await http
          .get(Uri.parse(_quoteEndpoint))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Server mengembalikan HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal melakukan request REST API: $e');
    }
  }
}