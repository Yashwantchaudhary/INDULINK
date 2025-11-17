import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'esewa/esewa_config.dart';
import 'esewa/esewa_flutter_sdk.dart';
import 'esewa/esewa_payment.dart';
import 'esewa/esewa_payment_success_result.dart';

class EsewaPaymentService {
  // ===== TEST ENVIRONMENT CREDENTIALS =====
  // SDK Integration Credentials
  static const String CLIENT_ID = "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  static const String SECRET_KEY = "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";

  // eSewa User Test Accounts (for payment testing)
  // eSewa ID: 9806800001 / 9806800002 / 9806800003 / 9806800004 / 9806800005
  // Password: Nepal@123
  // MPIN: 1122

  // Merchant Details for Verification
  static const String MERCHANT_ID = "EPAYTEST";
  static const String MERCHANT_SECRET = SECRET_KEY; // Same as SECRET_KEY for test

  // ===== LIVE ENVIRONMENT CREDENTIALS =====
  // Replace with actual production values from eSewa dashboard
  // static const String CLIENT_ID = "your_live_client_id";
  // static const String SECRET_KEY = "your_live_secret_key";
  // static const String MERCHANT_ID = "your_live_merchant_id";

  /// Initialize eSewa payment
  static Future<void> initiatePayment({
    required String productId,
    required String productName,
    required String amount,
    required BuildContext context,
    required Function(EsewaPaymentSuccessResult) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onCancellation,
  }) async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test, // Change to Environment.live for production
          clientId: CLIENT_ID,
          secretId: SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: productId,
          productName: productName,
          productPrice: amount,
          callbackUrl: "https://your-callback-url.com", // Replace with your actual callback URL
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(":::SUCCESS::: => $data");
          verifyTransactionStatus(data, context);
          onSuccess(data);
        },
        onPaymentFailure: (data) {
          debugPrint(":::FAILURE::: => $data");
          onFailure(data);
        },
        onPaymentCancellation: (data) {
          debugPrint(":::CANCELLATION::: => $data");
          onCancellation(data);
        },
      );
    } on Exception catch (e) {
      debugPrint("EXCEPTION : ${e.toString()}");
      onFailure(e.toString());
    }
  }

  /// Verify transaction status with eSewa API
  static Future<void> verifyTransactionStatus(
    EsewaPaymentSuccessResult result,
    BuildContext context,
  ) async {
    try {
      // For test environment
      final String verificationUrl = "https://rc.esewa.com.np/mobile/transaction";

      final response = await http.get(
        Uri.parse(
          "$verificationUrl?productId=${result.productId}&amount=${result.totalAmount}",
        ),
        headers: {
          'merchantId': MERCHANT_ID, // EPAYTEST for test environment
          'merchantSecret': MERCHANT_SECRET,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var map = {'data': json.decode(response.body)};
        final sucResponse = EsewaPaymentSuccessResponse.fromJson(map);

        debugPrint("Response Code => ${sucResponse.data}");

        if (sucResponse.data.isNotEmpty &&
            sucResponse.data[0].transactionDetails?.status == 'COMPLETE') {
          // Transaction verified successfully
          _showSuccessDialog(context, "Payment verified successfully!");
        } else {
          // Transaction verification failed
          _showErrorDialog(context, "Payment verification failed");
        }
      } else {
        _showErrorDialog(context, "Failed to verify payment");
      }
    } catch (e) {
      debugPrint("Verification error: $e");
      _showErrorDialog(context, "Error verifying payment: $e");
    }
  }

  /// Show success dialog
  static void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Example usage for hostel booking payment
  static Future<void> payForHostelBooking({
    required String bookingId,
    required String hostelName,
    required String amount,
    required BuildContext context,
  }) async {
    await initiatePayment(
      productId: bookingId,
      productName: "Hostel Booking - $hostelName",
      amount: amount,
      context: context,
      onSuccess: (result) {
        // Handle successful payment
        debugPrint("Payment successful for booking: $bookingId");
        // Update booking status in your backend
        // Navigate to success screen
      },
      onFailure: (error) {
        // Handle payment failure
        debugPrint("Payment failed: $error");
        // Show error message to user
      },
      onCancellation: (data) {
        // Handle payment cancellation
        debugPrint("Payment cancelled: $data");
        // Show cancellation message
      },
    );
  }
}

/// Extension for EsewaPaymentSuccessResponse (you may need to create this class)
class EsewaPaymentSuccessResponse {
  final List<EsewaTransactionData> data;

  EsewaPaymentSuccessResponse({required this.data});

  factory EsewaPaymentSuccessResponse.fromJson(Map<String, dynamic> json) {
    return EsewaPaymentSuccessResponse(
      data: (json['data'] as List)
          .map((item) => EsewaTransactionData.fromJson(item))
          .toList(),
    );
  }
}

class EsewaTransactionData {
  final EsewaTransactionDetails? transactionDetails;

  EsewaTransactionData({this.transactionDetails});

  factory EsewaTransactionData.fromJson(Map<String, dynamic> json) {
    return EsewaTransactionData(
      transactionDetails: json['transactionDetails'] != null
          ? EsewaTransactionDetails.fromJson(json['transactionDetails'])
          : null,
    );
  }
}

class EsewaTransactionDetails {
  final String? status;

  EsewaTransactionDetails({this.status});

  factory EsewaTransactionDetails.fromJson(Map<String, dynamic> json) {
    return EsewaTransactionDetails(
      status: json['status'],
    );
  }
}