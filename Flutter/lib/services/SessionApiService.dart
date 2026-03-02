import 'package:http/http.dart' as http;
import 'dart:convert';

class SessionApiService {
  static const String baseUrl = 'http://10.33.135.43:8000/api/sessions';

  Future<Map<String, dynamic>> getSessions({
    String? patientId,
    String? doctorId,
    String? status,
    int skip = 0,
    int limit = 10,
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (patientId != null && patientId.isNotEmpty) {
        queryParams['patient_id'] = patientId;
      }
      if (doctorId != null && doctorId.isNotEmpty) {
        queryParams['doctor_id'] = doctorId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      queryParams['skip'] = skip.toString();
      queryParams['limit'] = limit.toString();
      queryParams['active_only'] = activeOnly.toString();

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Session error: $e');
    }
  }
}
