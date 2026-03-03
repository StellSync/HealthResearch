import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_research/models/User.dart';

class UserApiService {
  static const String baseUrl = 'http://10.55.234.43:8000/api/patients';

  Future<User?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Parse the API response directly
        User user = User.fromJson({
          'patient_id': jsonResponse['patient_id'],
          'first_name': jsonResponse['first_name'],
          'email': jsonResponse['email'],
          'has_assigned_doctors': jsonResponse['has_assigned_doctors'],
        });

        return user;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception(
            'Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}
