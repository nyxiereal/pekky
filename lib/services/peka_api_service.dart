import 'dart:convert';
import 'package:http/http.dart' as http;
import 'peka_auth_service.dart';
import '../models/peka_models.dart';

class PekaApiService {
  static const String _baseUrl = 'https://www.peka.poznan.pl';
  final PekaAuthService _authService;

  PekaApiService(this._authService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getJwtToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 16; Samsung Smart Fridge)',
      'Accept-Encoding': 'gzip',
    };
  }

  Future<CustomerData> getCustomerData() async {
    final headers = await _getHeaders();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final url = Uri.parse(
      '$_baseUrl/sop/account/getCustomerData?lang=en&t=$timestamp',
    );

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final code = responseData['code'] as int?;

      if (code == 0) {
        return CustomerData.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to get customer data: code $code');
      }
    } else {
      throw Exception('Failed to get customer data: ${response.statusCode}');
    }
  }

  Future<List<PekaCard>> getCards() async {
    final headers = await _getHeaders();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final url = Uri.parse('$_baseUrl/sop/account/cards?lang=en&t=$timestamp');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final code = responseData['code'] as int?;

      if (code == 0) {
        final cardsData = responseData['data'] as List<dynamic>;
        return cardsData
            .map((card) => PekaCard.fromJson(card as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get cards: code $code');
      }
    } else {
      throw Exception('Failed to get cards: ${response.statusCode}');
    }
  }

  Future<List<Ticket>> getTickets() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl/sop/account/tickets?lang=en');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final code = responseData['code'] as int?;

      if (code == 0) {
        final ticketsData = responseData['data'] as List<dynamic>;
        return ticketsData
            .map((ticket) => Ticket.fromJson(ticket as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get tickets: code $code');
      }
    } else {
      throw Exception('Failed to get tickets: ${response.statusCode}');
    }
  }

  Future<List<PaymentCard>> getPaymentCards() async {
    final headers = await _getHeaders();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final url = Uri.parse(
      '$_baseUrl/sop/account/paymentCards?lang=en&t=$timestamp',
    );

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final code = responseData['code'] as int?;

      if (code == 0) {
        final cardsData = responseData['data'] as List<dynamic>;
        return cardsData
            .map((card) => PaymentCard.fromJson(card as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get payment cards: code $code');
      }
    } else {
      throw Exception('Failed to get payment cards: ${response.statusCode}');
    }
  }
}
