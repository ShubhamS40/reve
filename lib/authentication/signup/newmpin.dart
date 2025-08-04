import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/login.dart';
import 'package:reva/services/signup/AuthenticationService.dart';

import '../components/mytextfield.dart';

class NewMPIN extends StatefulWidget {
  const NewMPIN({super.key});

  @override
  State<NewMPIN> createState() => _NewMPINState();
}

class _NewMPINState extends State<NewMPIN> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController mpinController = TextEditingController();
  final TextEditingController confirmmpinController = TextEditingController();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final Authenticationservice _authService = Authenticationservice();
  Future<void> _resetMpin() async {
    // Validate inputs
    if (mpinController.text.isEmpty || confirmmpinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both MPIN and Confirm MPIN';
      });
      return;
    }

    if (mpinController.text.length != 6 ||
        !RegExp(r'^[0-9]{6}$').hasMatch(mpinController.text)) {
      setState(() {
        _errorMessage = 'MPIN must be 6 digits';
      });
      return;
    }

    if (mpinController.text != confirmmpinController.text) {
      setState(() {
        _errorMessage = 'MPINs do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get mobile number from secure storage
      final mobileNumber = await _secureStorage.read(key: 'mobileNumber');

      if (mobileNumber == null) {
        setState(() {
          _errorMessage = 'Mobile number not found. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Get userId from secure storage
      final userId = await _secureStorage.read(key: 'userId');

      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not found. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Call reset MPIN API
      final success =
          await _authService.resetMpin(mobileNumber, mpinController.text);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MPIN reset successful')),
        );

        // Navigate to login screen
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        setState(() {
          _errorMessage = 'Failed to reset MPIN. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
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
                        SizedBox(height: height * 0.1),
                        Center(
                          child: Text(
                            "Reset MPIN",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'MPIN',
                          hint: '666 666',
                          controller: mpinController,
                          isPassword: true,
                          obscureText: !isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        CustomTextField(
                          label: 'Confirm MPIN',
                          hint: '666 666',
                          controller: confirmmpinController,
                          isPassword: true,
                          obscureText: !isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetMpin,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor:
                                  Colors.grey.withOpacity(0.3),
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
                                color: _isLoading
                                    ? Colors.grey.withOpacity(0.3)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Reset MPIN',
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
                        Spacer(),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Remember your MPIN? ",
                                style: TextStyle(color: Color(0xFFD8D8DD)),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()));
                                },
                                child: const Text(
                                  "Login",
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
