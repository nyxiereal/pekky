import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum AuthError { invalidCredentials, deviceWaitRequired, networkError, unknown }

class AuthException implements Exception {
  final AuthError error;
  final String message;

  AuthException(this.error, this.message);

  @override
  String toString() => message;
}

class PekaAuthService {
  static const String _baseUrl = 'https://www.peka.poznan.pl';
  static const String _appIdKey = 'app_id';
  static const String _emailKey = 'saved_email';
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _jwtTokenKey = 'jwt_token';

  final Uuid _uuid = const Uuid();

  // Get or create a persistent app ID
  Future<String> getAppId() async {
    final prefs = await SharedPreferences.getInstance();
    String? appId = prefs.getString(_appIdKey);

    if (appId == null) {
      appId = _uuid.v4();
      await prefs.setString(_appIdKey, appId);
    }

    return appId;
  }

  // Allow user to export their app ID
  Future<String> exportAppId() async {
    return await getAppId();
  }

  // Allow user to import a custom app ID
  Future<void> importAppId(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appIdKey, appId);
  }

  // Authenticate with PEKA
  Future<void> authenticate({
    required String email,
    required String password,
  }) async {
    final appId = await getAppId();

    final url = Uri.parse('$_baseUrl/sop/authenticate-mobile?lang=en');

    final body = jsonEncode({
      'appId': appId,
      'appName': '---',
      'password': password,
      'username': email,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 16; Pekky App)',
          'Accept-Encoding': 'gzip',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Check for successful authentication with code:0
        final responseData = jsonDecode(response.body);
        final code = responseData['code'] as int?;

        if (code == 0) {
          // Successful authentication - extract JWT token
          final jwtToken = responseData['data'] as String?;

          if (jwtToken != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_isAuthenticatedKey, true);
            await prefs.setString(_emailKey, email);
            await prefs.setString(_jwtTokenKey, jwtToken);
          } else {
            throw AuthException(
              AuthError.unknown,
              'No token received from server',
            );
          }
        } else {
          // Non-zero code means authentication failed
          throw AuthException(
            AuthError.unknown,
            'Authentication failed with code: $code',
          );
        }
      } else if (response.statusCode == 401) {
        // Check if there's a body with error details
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage = errorData['errMsg'] as String?;

            if (errorMessage != null &&
                errorMessage.contains('24 hours after your last sign in')) {
              throw AuthException(
                AuthError.deviceWaitRequired,
                'On a new device, you can sign in 24 hours after your last sign in',
              );
            }
          } catch (e) {
            if (e is AuthException) rethrow;
            // If JSON parsing fails, fall through to invalid credentials
          }
        }

        // Empty 401 response means invalid credentials
        throw AuthException(
          AuthError.invalidCredentials,
          'Invalid email or password',
        );
      } else {
        throw AuthException(
          AuthError.unknown,
          'Authentication failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;

      throw AuthException(
        AuthError.networkError,
        'Network error: ${e.toString()}',
      );
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Get JWT token
  Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, false);
    await prefs.remove(_emailKey);
    await prefs.remove(_jwtTokenKey);
  }

  // Reset app ID (for testing or starting fresh)
  Future<void> resetAppId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appIdKey);
  }
}
