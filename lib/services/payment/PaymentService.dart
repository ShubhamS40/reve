import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../signup/AuthenticationService.dart';

class PaymentService {
  final Authenticationservice _authenticationservice = Authenticationservice();
  final String baseUrl = 'http://192.168.0.101:3000/index';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Razorpay _razorpay;

  PaymentService() {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  // Create a new order with Razorpay
  Future<Map<String, dynamic>?> createOrder(int amount) async {
    try {
      final response = await _authenticationservice.authenticatedPost(
        'payment/create-order',
        body: {'amount': amount},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'],
          'orderId': data['orderId'],
          'amount': data['amount'],
          'key': data['key'],
        };
      } else {
        print('Error creating order: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception creating order: $e');
      return null;
    }
  }

  // Open Razorpay payment gateway
  Future<void> openRazorpayCheckout({
    required String orderId,
    required int amount,
    required String key,
    required String description,
    required String name,
    String? email,
    required String contact,
  }) async {
    var options = {
      'key': key,
      'amount': amount, // Amount is in paise
      'order_id': orderId,
      'name': name,
      'description': description,
      'timeout': 300, // in seconds
      'prefill': {
        'contact': contact,
        'email': email ?? '',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay checkout: $e');
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment success: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');

    // You can add additional logic here to update your backend
    // For example, verify the payment with your backend
    // await _verifyPayment(response.orderId, response.paymentId, response.signature);
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment error: ${response.code} - ${response.message}');
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
  }

  // Set payment success callback
  void setPaymentSuccessCallback(Function(PaymentSuccessResponse) callback) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, callback);
  }

  // Set payment error callback
  void setPaymentErrorCallback(Function(PaymentFailureResponse) callback) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, callback);
  }

  // Set external wallet callback
  void setExternalWalletCallback(Function(ExternalWalletResponse) callback) {
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, callback);
  }
}
