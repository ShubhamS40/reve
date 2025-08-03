import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/login.dart';
import 'package:reva/authentication/signup/CompleteProfileScreen.dart';
import 'package:reva/models/signup/authenticationmodel.dart';
import 'package:reva/services/signup/AuthenticationService.dart';

import '../components/mytextfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FlutterSecureStorage _flutterSecureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // iOptions: IOSOptions(accessibility: IOSAccessibility.first_unlock),
  );
  bool isPasswordVisible = false;
  bool isRememberMe = false;
  bool isConfirmPasswordVisible = false;
  bool _isLoading = false;
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mpinController = TextEditingController();
  TextEditingController confirmmpinController = TextEditingController();
  final Authenticationservice authenticationservice = Authenticationservice();

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
                            "Signup",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        CustomTextField(
                          label: 'First Name',
                          hint: 'First Name',
                          controller: firstNameController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Last Name',
                          hint: 'Last Name',
                          controller: lastNameController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Mobile Number',
                          hint: 'Mobile Number',
                          controller: mobileNumberController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'MPIN',
                          hint: 'MPIN',
                          controller: mpinController,
                          isPassword: true,
                          obscureText: !isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomTextField(
                          label: 'Confirm MPIN',
                          hint: 'Confirm MPIN',
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
                        const SizedBox(height: 16),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Validate inputs
                              String mobilenumber =
                                  mobileNumberController.text.trim();
                              String firstName =
                                  firstNameController.text.trim();
                              String lastName = lastNameController.text.trim();
                              String mpin = mpinController.text.trim();
                              String confirmMpin =
                                  confirmmpinController.text.trim();

                              // Validate all fields are filled
                              if (mobilenumber.isEmpty ||
                                  firstName.isEmpty ||
                                  lastName.isEmpty ||
                                  mpin.isEmpty ||
                                  confirmMpin.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please fill all fields")),
                                );
                                return;
                              }

                              // Validate mobile number format
                              if (mobilenumber.length != 10 ||
                                  !RegExp(r'^[0-9]{10}$')
                                      .hasMatch(mobilenumber)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Please enter a valid 10-digit mobile number")),
                                );
                                return;
                              }

                              // Validate MPIN
                              if (mpin.length < 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "MPIN should be at least 4 digits")),
                                );
                                return;
                              }

                              // Validate MPIN and confirm MPIN match
                              if (mpin != confirmMpin) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "MPIN and Confirm MPIN do not match")),
                                );
                                return;
                              }

                              // Set loading state
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                // Save mobile number to secure storage
                                await _flutterSecureStorage.write(
                                    key: 'mobileNumber', value: mobilenumber);

                                // Attempt signup
                                Users? user =
                                    await authenticationservice.Signup(
                                        firstName,
                                        lastName,
                                        mobilenumber,
                                        mpin);

                                // Reset loading state
                                setState(() {
                                  _isLoading = false;
                                });

                                if (user != null) {
                                  // Navigate to complete profile screen on success
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CompleteProfileScreen()));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Signup failed. Please try again.")),
                                  );
                                }
                              } catch (e) {
                                // Reset loading state
                                setState(() {
                                  _isLoading = false;
                                });

                                // Handle specific error messages
                                String errorMessage =
                                    "Signup failed. Please try again.";
                                if (e.toString().contains("already exists")) {
                                  errorMessage =
                                      "User with this mobile number already exists.";
                                } else if (e
                                    .toString()
                                    .contains("Connection")) {
                                  errorMessage =
                                      "Connection error. Please check your internet connection.";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );

                                print("Signup error: ${e.toString()}");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0262AB),
                                    Color(0xFF01345A)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Signup',
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
                                "Already have an account! ",
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
