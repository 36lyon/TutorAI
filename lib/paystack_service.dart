import 'dart:convert';
import 'dart:io';

import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';

class TutorPaystackPaymentResult {
  final bool success;
  final String message;
  final String reference;
  final String transactionStatus;
  final Map<String, dynamic>? verification;

  const TutorPaystackPaymentResult({
    required this.success,
    required this.message,
    this.reference = '',
    this.transactionStatus = '',
    this.verification,
  });
}

class TutorPaystackService {
  static const String _backendUrl = String.fromEnvironment(
    'TUTORAI_BACKEND_URL',
    defaultValue: '',
  );

  final Paystack _paystack = Paystack();

  Uri _uri(String path) {
    final base = _backendUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$base$path');
  }

  Future<TutorPaystackPaymentResult> startSubscription({
    required String email,
    required String plan,
  }) async {
    if (_backendUrl.trim().isEmpty) {
      return const TutorPaystackPaymentResult(
        success: false,
        message: 'TutorAI backend is not configured.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPlan = plan.trim().toLowerCase();

    if (!normalizedEmail.contains('@')) {
      return const TutorPaystackPaymentResult(
        success: false,
        message: 'Please enter a valid email address.',
      );
    }

    if (!['weekly', 'monthly', 'yearly'].contains(normalizedPlan)) {
      return const TutorPaystackPaymentResult(
        success: false,
        message: 'Invalid Premium plan.',
      );
    }

    try {
      final initialize = await _postJson(
        '/v1/paystack/initialize',
        <String, dynamic>{
          'email': normalizedEmail,
          'plan': normalizedPlan,
        },
      );

      final publicKey = initialize['publicKey'];
      final accessCode = initialize['accessCode'];
      final reference = initialize['reference'];

      if (publicKey is! String ||
          accessCode is! String ||
          reference is! String ||
          publicKey.trim().isEmpty ||
          accessCode.trim().isEmpty ||
          reference.trim().isEmpty) {
        return const TutorPaystackPaymentResult(
          success: false,
          message: 'Paystack initialization returned incomplete data.',
        );
      }

      final initialized = await _paystack.initialize(publicKey, true);

      if (!initialized) {
        return const TutorPaystackPaymentResult(
          success: false,
          message: 'TutorAI could not initialize the Paystack payment screen.',
        );
      }

      final payment = await _paystack.launch(accessCode);

      if (payment.status.toLowerCase() != 'success') {
        return TutorPaystackPaymentResult(
          success: false,
          message: payment.message,
          reference: payment.reference,
        );
      }

      final verified = await _postJson(
        '/v1/paystack/verify',
        <String, dynamic>{
          'reference': payment.reference.isNotEmpty
              ? payment.reference
              : reference,
        },
      );

      final verifiedStatus = verified['transactionStatus'];
      final verifiedReference = verified['reference'];

      if (verifiedStatus != 'success') {
        return TutorPaystackPaymentResult(
          success: false,
          message: 'Paystack payment could not be verified.',
          reference: verifiedReference is String
              ? verifiedReference
              : reference,
          transactionStatus: verifiedStatus is String
              ? verifiedStatus
              : '',
          verification: verified,
        );
      }

      return TutorPaystackPaymentResult(
        success: true,
        message: 'TutorAI Premium payment verified successfully.',
        reference: verifiedReference is String
            ? verifiedReference
            : reference,
        transactionStatus: 'success',
        verification: verified,
      );
    } catch (error) {
      return TutorPaystackPaymentResult(
        success: false,
        message: 'Paystack payment error: $error',
      );
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    client.idleTimeout = const Duration(seconds: 15);

    try {
      final request = await client.postUrl(_uri(path)).timeout(
            const Duration(seconds: 10),
          );

      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode(payload));

      final response = await request.close().timeout(
            const Duration(seconds: 30),
          );

      final body = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $body',
        );
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Backend returned an invalid JSON object.',
        );
      }

      if (decoded['status'] != true) {
        throw Exception(
          decoded['error']?.toString() ??
              'Paystack backend request failed.',
        );
      }

      return decoded;
    } finally {
      client.close(force: true);
    }
  }
}