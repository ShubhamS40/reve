import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../signup/AuthenticationService.dart';

class SubscriptionService {
  final Authenticationservice _authenticationservice = Authenticationservice();

  // Update this to your actual server URL
  final String baseUrl =
      'http://192.168.0.101:3000'; // Change localhost to your server IP for device testing
  final String subscriptionPath = '/index/subscription/plans';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Check if the user has an active subscription
  Future<Map<String, dynamic>?> checkSubscription() async {
    try {
      String? userId = await _secureStorage.read(key: 'userId');
      if (userId == null) {
        return {'hasActiveSubscription': false, 'message': 'User ID not found'};
      }

      // Use the checkSubscription method from AuthenticationService
      bool hasSubscription =
          await _authenticationservice.checkSubscription(userId);

      return {
        'hasActiveSubscription': hasSubscription,
        'message': hasSubscription
            ? 'Active subscription found'
            : 'No active subscription'
      };
    } catch (e) {
      print('Exception checking subscription: $e');
      return {
        'hasActiveSubscription': false,
        'message': 'Error checking subscription'
      };
    }
  }

  // Simple check for active subscription (returns bool)
  Future<bool> hasActiveSubscription() async {
    try {
      final result = await checkSubscription();
      return result?['hasActiveSubscription'] ?? false;
    } catch (e) {
      print('Exception checking subscription status: $e');
      return false;
    }
  }

  // Get all available subscription plans
  Future<Map<String, dynamic>?> getSubscriptionPlans() async {
    try {
      print(
          'Fetching subscription plans from: $baseUrl$subscriptionPath/plans');

      final response = await http.get(
        Uri.parse('$baseUrl$subscriptionPath/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both direct plans array and wrapped response
        if (data is List) {
          return <String, dynamic>{'plans': data};
        } else if (data is Map && data.containsKey('plans')) {
          return Map<String, dynamic>.from(data);
        } else {
          print('Unexpected response format: $data');
          return null;
        }
      } else {
        print('Error fetching subscription plans: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception fetching subscription plans: $e');
      return null;
    }
  }

  // Create a new subscription
  Future<Map<String, dynamic>?> createSubscription({
    required String planId,
    int? customDuration,
    String? paymentId,
    String? paymentMethod,
  }) async {
    try {
      final body = {
        'planId': planId,
        if (customDuration != null) 'customDuration': customDuration,
        if (paymentId != null) 'paymentId': paymentId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };

      print('Creating subscription with body: $body');

      final response = await _authenticationservice.authenticatedPost(
        'subscription/create',
        body: body,
      );

      print('Create subscription response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error creating subscription: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return errorData;
      }
    } catch (e) {
      print('Exception creating subscription: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // Cancel active subscription
  Future<Map<String, dynamic>?> cancelSubscription({String? reason}) async {
    try {
      final body = {
        if (reason != null) 'reason': reason,
      };

      final response = await _authenticationservice.authenticatedPost(
        'subscription/cancel',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error cancelling subscription: ${response.statusCode}');
        print('Response body: ${response.body}');
        final errorData = jsonDecode(response.body);
        return errorData;
      }
    } catch (e) {
      print('Exception cancelling subscription: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // Helper method to get plan by name
  Future<Map<String, dynamic>?> getPlanByName(String planName) async {
    try {
      final response = await getSubscriptionPlans();
      if (response != null && response['plans'] != null) {
        final plans = response['plans'] as List;
        for (var plan in plans) {
          if (plan['name'].toString().toLowerCase() == planName.toLowerCase()) {
            return plan;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting plan by name: $e');
      return null;
    }
  }

  // Helper method to get plans by duration type
  Future<List<dynamic>> getPlansByDurationType(String durationType) async {
    try {
      final response = await getSubscriptionPlans();
      if (response != null && response['plans'] != null) {
        final plans = response['plans'] as List;
        return plans
            .where((plan) =>
                plan['durationType'].toString().toLowerCase() ==
                durationType.toLowerCase())
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting plans by duration type: $e');
      return [];
    }
  }

  // Calculate total price for custom duration
  double calculateTotalPrice(double monthlyPrice, int months) {
    return monthlyPrice * months;
  }

  // Format currency
  String formatCurrency(double amount, {String currency = 'INR'}) {
    switch (currency) {
      case 'INR':
        return '₹${amount.toStringAsFixed(0)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  // Get subscription status text
  String getSubscriptionStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending Payment';
      default:
        return 'Unknown';
    }
  }

  // Validate plan data
  bool isValidPlan(Map<String, dynamic>? plan) {
    if (plan == null) return false;

    return plan.containsKey('_id') &&
        plan.containsKey('name') &&
        plan.containsKey('price') &&
        plan.containsKey('durationType') &&
        plan['isActive'] == true;
  }

  // Get plan display name
  String getPlanDisplayName(String planName) {
    switch (planName.toLowerCase()) {
      case 'silver':
        return 'Silver Plan';
      case 'gold':
        return 'Gold Plan';
      case 'platinum':
        return 'Platinum Plan';
      default:
        return '${planName.toUpperCase()} Plan';
    }
  }

  // Get plan benefits text
  String getBenefitsText(List<dynamic>? benefits) {
    if (benefits == null || benefits.isEmpty) {
      return 'Premium features included';
    }
    return benefits.join(' • ');
  }
}
