import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/newmpin.dart';
import 'package:reva/services/signup/AuthenticationService.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late final Authenticationservice _authService;

  String? _userId;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _authService = Authenticationservice();
    _loadStoredMobileNumber();
    _setupOtpControllers();
  }

  void _setupOtpControllers() {
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        final text = _otpControllers[i].text;
        if (text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        // Auto-verify when all fields are filled
        if (i == 5 && text.isNotEmpty) {
          _checkAutoVerify();
        }
      });
    }
  }

  void _checkAutoVerify() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6 && _isOtpSent && !_isLoading) {
      _verifyOtp();
    }
  }

  Future<void> _loadStoredMobileNumber() async {
    try {
      final storedNumber = await _secureStorage.read(key: 'mobileNumber');
      if (storedNumber != null && storedNumber.isNotEmpty) {
        setState(() {
          _mobileNumberController.text = storedNumber;
        });
      }
    } catch (e) {
      print('Error loading stored mobile number: $e');
    }
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 30;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    final mobileNumber = _mobileNumberController.text.trim();

    if (mobileNumber.isEmpty) {
      _showError('Please enter your mobile number');
      return;
    }

    if (!_isValidMobileNumber(mobileNumber)) {
      _showError('Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      if (isResend) {
        _isResending = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final result = await _authService.sendOtp(mobileNumber);

      if (mounted) {
        if (result != null) {
          setState(() {
            _isOtpSent = true;
            _userId = result['userId'] as String;
            _isLoading = false;
            _isResending = false;
          });

          // Store mobile number for future use
          await _secureStorage.write(key: 'mobileNumber', value: mobileNumber);

          // Start countdown for resend
          _startResendCountdown();

          // Focus on first OTP field
          _focusNodes[0].requestFocus();

          _showSuccessMessage(
              isResend ? 'OTP resent successfully' : 'OTP sent successfully');
        } else {
          setState(() {
            _isLoading = false;
            _isResending = false;
          });
          _showError(result != null && result.containsKey('message')
              ? result['message'] as String
              : 'Failed to send OTP. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isResending = false;
        });
        _showError(
            'Network error. Please check your connection and try again.');
        print('Send OTP error: $e');
      }
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      _showError('Please enter the complete 6-digit OTP');
      return;
    }

    if (_userId == null) {
      _showError('Session expired. Please send OTP again.');
      _resetOtpState();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.verifyOtp(otp, _userId!);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result == true) {
          // Navigate to reset MPIN screen
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const NewMPIN()));
        } else {
          _showError('Invalid OTP. Please try again.');
          _clearOtpFields();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Verification failed. Please try again.');
        print('Verify OTP error: $e');
      }
    }
  }

  bool _isValidMobileNumber(String number) {
    return number.length == 10 && RegExp(r'^[6-9][0-9]{9}$').hasMatch(number);
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _resetOtpState() {
    setState(() {
      _isOtpSent = false;
      _userId = null;
      _resendCountdown = 0;
    });
    _clearOtpFields();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.03),

                // Title
                Center(
                  child: Text(
                    'Forgot MPIN',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                Center(
                  child: Text(
                    _isOtpSent
                        ? 'Enter the 6-digit OTP sent to your mobile number'
                        : 'Enter your mobile number to receive OTP',
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Mobile Number Input
                const Text(
                  'Mobile Number',
                  style: TextStyle(
                    color: Color(0xFFD8D8DD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: height * 0.01),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3138),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _errorMessage != null
                          ? Colors.red.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: TextField(
                    controller: _mobileNumberController,
                    keyboardType: TextInputType.number,
                    enabled: !_isOtpSent,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Enter 10-digit mobile number',
                      hintStyle: TextStyle(color: Color(0xFF6F6F6F)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      counterText: '',
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Send OTP Button (shown when OTP not sent)
                if (!_isOtpSent)
                  SizedBox(
                    width: double.infinity,
                    height: height * 0.065,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _sendOtp(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
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
                                  'Send OTP',
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

                // OTP Section (shown when OTP is sent)
                if (_isOtpSent) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          color: Color(0xFFD8D8DD),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendCountdown > 0 || _isResending
                            ? null
                            : () => _sendOtp(isResend: true),
                        child: Text(
                          _resendCountdown > 0
                              ? 'Resend in ${_resendCountdown}s'
                              : _isResending
                                  ? 'Resending...'
                                  : 'Resend OTP',
                          style: TextStyle(
                            color: _resendCountdown > 0 || _isResending
                                ? const Color(0xFF6F6F6F)
                                : const Color(0xFF3B9FED),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.03),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => Container(
                        width: width * 0.12,
                        height: width * 0.12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E3138),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _otpControllers[index].text.isNotEmpty
                                ? const Color(0xFF0262AB)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // Verify OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: height * 0.065,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
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
                                  'Verify OTP',
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
                ],

                SizedBox(height: height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
