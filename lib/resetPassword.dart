import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isLoading = false;

  Future<void> _sendOfficialResetEmail() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: widget.email);

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Email Sent'),
            content: Text(
              'A password reset link has been sent to:\n\n${widget.email}\n\n'
                  'Please open your email and follow the instructions to set a new password.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // After sending email, go back to login screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      _showMessageDialog(
        title: 'Error',
        message: e.message ?? 'Failed to send reset email.',
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
              color: isError ? Colors.red : Colors.green,
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
        title: const Text("Reset Password"),
        backgroundColor: const Color(0xFF3A4A91), // Accent blue color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // OTP Verified Text
            const Text(
              "OTP verified successfully ✅",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            // Instruction Text
            Text(
              "To securely change your password, we will send an official "
                  "password reset link to this email:\n\n${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Send Reset Email Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOfficialResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A4A91), // Accent blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Send Reset Email",
                  style: TextStyle(fontSize: 18,color: Colors.white),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
