import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_app_2/otpVerification.dart';
import 'package:flutter_firebase_app_2/notifications_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // Generate a random 6-digit OTP
  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Email validation method using regex
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    // Regex pattern for a valid email format like "xxJxxxx@utas.edu.om" or "xxjxxxx@utas.edu.om"
    if (!RegExp(r'\b[0-9]{2,3}[JjSs][0-9]+@utas\.edu\.om\b', caseSensitive: false).hasMatch(value)) {
      return 'Please enter a valid email address in the format "xxJ/Sxxxx@utas.edu.om"';
    }
    return null;
  }

  Future<void> _checkEmailAndSendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final rawEmail = emailController.text.trim();
    final email = rawEmail.toLowerCase();

    setState(() => _isLoading = true);

    try {
      // Use FirebaseAuth to verify that the email exists.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      final otp = _generateOtp();

      // 💬 Show OTP as a local notification instead of dialog
      await NotificationHelper.showNotification(
        title: 'Verification Code',
        body: 'Your 6-digit OTP is: $otp',
      );

      // Navigate to OTP verification page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            email: rawEmail, // show as user typed it
            otp: otp,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessageDialog(
          title: 'Email Not Found',
          message: 'This email is not registered in our system.',
          isError: true,
        );
      } else {
        _showMessageDialog(
          title: 'Error',
          message: e.message ?? 'Something went wrong.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessageDialog(
        title: 'Error',
        message: 'Something went wrong: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: isError ? Colors.red : Colors.blueAccent,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAFF), // Light lavender background
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: const Color(0xFF3A4A91), // Accent blue color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 40),
            // Title
            const Text(
              "Enter your email to receive a 6-digit verification code.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF3A4A91), // Accent blue color
              ),
            ),
            const SizedBox(height: 30),
            // Email Input Field
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: emailValidator,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: const Icon(Icons.email, color: Color(0xFF3A4A91)),
                labelStyle: const TextStyle(color: Color(0xFF3A4A91)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3A4A91)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF3A4A91)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Send OTP Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkEmailAndSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A4A91), // Accent blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Send OTP",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
