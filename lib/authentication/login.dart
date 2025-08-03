import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/signup.dart';
import 'package:reva/authentication/signup/otpscreen.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'package:reva/home/homescreen.dart';
import 'package:reva/services/signup/AuthenticationService.dart';
import 'package:reva/subscription/subscriptionscreen.dart';

import 'components/mytextfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool ismpinVisible = false;
  bool isRememberMe = false;
  bool _isLoading = false;

  final TextEditingController mpinController = TextEditingController();
  final FlutterSecureStorage _flutterSecureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Move authentication service to class level to avoid recreation
  late final Authenticationservice _authenticationservice;

  @override
  void initState() {
    super.initState();
    _authenticationservice = Authenticationservice();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    mpinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (mpinController.text.trim().isEmpty) {
      _showSnackBar('Please enter your MPIN');
      return;
    }

    try {
      String? mobileNumber =
          await _flutterSecureStorage.read(key: 'mobileNumber');
      print("Mobile number: $mobileNumber");

      if (mobileNumber == null || mobileNumber.isEmpty) {
        _showSnackBar('No mobile number found. Please sign up first.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final user = await _authenticationservice.Login(
          mobileNumber, mpinController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          // Get userId from secure storage
          String? userId = await _flutterSecureStorage.read(key: 'userId');

          if (userId != null) {
            // Check if user has an active subscription
            bool hasSubscription =
                await _authenticationservice.checkSubscription(userId);

            if (hasSubscription) {
              // If user has subscription, navigate to home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavigation()),
              );
            } else {
              // If user doesn't have subscription, navigate to subscription screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionPlansScreen(userId: userId),
                ),
              );
            }
          } else {
            _showSnackBar('User ID not found. Please login again.');
          }
        } else {
          _showSnackBar('Login failed. Please check your credentials.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = _getErrorMessage(e.toString());
        _showSnackBar(errorMessage);

        print("Login error: ${e.toString()}");
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Authentication failed')) {
      return 'Authentication failed. Please login again.';
    } else if (error.contains('Connection')) {
      return 'Connection error. Please check your internet connection.';
    } else if (error.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.contains('Invalid MPIN')) {
      return 'Invalid MPIN. Please try again.';
    }
    return 'Login failed. Please try again.';
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.15),
                        Center(
                          child: Image.asset(
                            "assets/login.png",
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.login,
                                size: 80,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'MPIN',
                          hint: 'Enter your MPIN',
                          controller: mpinController,
                          isPassword: true,
                          obscureText: !ismpinVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              ismpinVisible = !ismpinVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OtpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey.shade600,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: _isLoading
                                    ? null
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF0262AB),
                                          Color(0xFF01345A)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(8),
                                color: _isLoading ? Colors.grey.shade600 : null,
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        const Spacer(),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Color(0xFFD8D8DD)),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUp(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Signup",
                                  style: TextStyle(
                                    color: Color(0xFF3B9FED),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
