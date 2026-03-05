import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_research/config/api_config.dart';
import 'package:health_research/models/DepressionResult.dart';

class DepressionApiService {
  Future<DepressionResult?> getDepressionResults(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl1}/api/results/depression/$userId'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return DepressionResult.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        // No depression results found, return empty result
        return DepressionResult(
          userId: userId,
          type: 'Depression',
          count: 0,
          results: [],
        );
      } else {
        throw Exception(
            'Failed to load depression results: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching depression results: $e');
    }
  }
}
