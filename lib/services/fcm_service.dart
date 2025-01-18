import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';

class FCMService {
  static ServiceAccountCredentials? _cachedCredentials;
  static DateTime? _lastTokenTime;
  static String? _cachedToken;

  static Future<ServiceAccountCredentials> _getCredentials() async {
    if (_cachedCredentials != null) return _cachedCredentials!;

    try {
      final serviceAccount =
          await rootBundle.loadString('assets/service-account.json');
      final jsonMap = json.decode(serviceAccount);

      // Validasi format service account
      if (!jsonMap.containsKey('private_key') ||
          !jsonMap.containsKey('client_email')) {
        throw Exception('Invalid service account format');
      }

      print(
          'Service account loaded: ${jsonMap['client_email']}'); // Debug print

      _cachedCredentials = ServiceAccountCredentials.fromJson(jsonMap);
      return _cachedCredentials!;
    } catch (e) {
      print('Error loading service account: $e');
      rethrow;
    }
  }

  static Future<String> _getAccessToken() async {
    // Cek apakah token masih valid (kurang dari 50 menit)
    if (_cachedToken != null && _lastTokenTime != null) {
      final difference = DateTime.now().difference(_lastTokenTime!);
      if (difference.inMinutes < 50) {
        return _cachedToken!;
      }
    }

    try {
      final credentials = await _getCredentials();

      print('Requesting new access token...'); // Debug print

      final client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      _cachedToken = client.credentials.accessToken.data;
      _lastTokenTime = DateTime.now();

      print('New access token obtained at: $_lastTokenTime'); // Debug print

      client.close();
      return _cachedToken!;
    } catch (e) {
      print('Error getting access token: $e');
      rethrow;
    }
  }

  static Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final projectId = 'flexnews-dc855';

      print('Preparing to send notification...'); // Debug print

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'message': {
            'topic': 'news_updates',
            'notification': {
              'title': title,
              'body': body,
            },
          },
        }),
      );

      print('Response Status Code: ${response.statusCode}'); // Debug print
      print('Response Body: ${response.body}'); // Debug print

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error in sendNotification: $e');
      rethrow;
    }
  }

  // Method untuk testing koneksi
  static Future<bool> testConnection() async {
    try {
      final credentials = await _getCredentials();
      print('Service Account Email: ${credentials.email}');
      print('Project ID: flexnews-dc855');
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
