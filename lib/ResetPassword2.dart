import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;

  String? _passwordStrengthError(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must include an uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must include a lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include a number.';
    }
    if (!RegExp(r"[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:',.<>\/\?\\|`~]").hasMatch(value)) {
      return 'Password must include a special character.';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmNewPasswordController.text;

    if (currentPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      _showMessageDialog(
        title: 'Error',
        message: 'Please fill in all password fields.',
        isError: true,
      );
      return;
    }

    final strengthError = _passwordStrengthError(newPassword);
    if (strengthError != null) {
      _showMessageDialog(
        title: 'Error',
        message: strengthError,
        isError: true,
      );
      return;
    }

    if (currentPassword == newPassword) {
      _showMessageDialog(
        title: 'Error',
        message: 'New password must be different from current password.',
        isError: true,
      );
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _showMessageDialog(
        title: 'Error',
        message: 'New password and confirm password do not match.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Reauthenticate user first to change password
        final credentials = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        // Reauthenticate the user
        await user.reauthenticateWithCredential(credentials);

        // Now update the password
        await user.updatePassword(_newPasswordController.text);
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        // Show success message
        _showMessageDialog(
          title: 'Success',
          message: 'Your password has been updated successfully.',
          isError: false,
        );

        // Wait for the dialog to close before navigating back
        await Future.delayed(const Duration(seconds: 2));

        // Go back to the previous screen after the success message
        Navigator.pop(context);  // Go back to the previous screen
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes
      if (e.code == 'wrong-password') {
        _showMessageDialog(
          title: 'Error',
          message: 'The current password is incorrect.',
          isError: true,
        );
      } else if (e.code == 'user-not-found') {
        _showMessageDialog(
          title: 'Error',
          message: 'No user found with this email address.',
          isError: true,
        );
      } else {
        _showMessageDialog(
          title: 'Error',
          message: e.message ?? 'Failed to reset password.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessageDialog(
        title: 'Error',
        message: 'An unexpected error occurred: $e',
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
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: const Color(0xFF3A4A91), // Consistent accent blue color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 40),
              const Text(
                "Change your password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Current Password Field
              _buildTextField(
                controller: _currentPasswordController,
                label: "Current Password",
                obscureText: true,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter your current password.' : null,
              ),
              const SizedBox(height: 15),

              // New Password Field
              _buildTextField(
                controller: _newPasswordController,
                label: "New Password",
                obscureText: true,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Please enter a new password.';
                  return _passwordStrengthError(value);
                },
              ),
              const SizedBox(height: 15),

              // Confirm New Password Field
              _buildTextField(
                controller: _confirmNewPasswordController,
                label: "Confirm New Password",
                obscureText: true,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Please confirm the new password.';
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4A91), // Accent blue color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5, // Slight shadow for elevation
                    padding: const EdgeInsets.symmetric(vertical: 15), // Padding
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF3A4A91)), // Consistent with the app color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF3A4A91)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF3A4A91)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}
