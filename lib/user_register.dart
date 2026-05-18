import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase_app_2/Login.dart';
import 'package:crypt/crypt.dart'; // Import the crypt package for hashing

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController levelController = TextEditingController();

  DateTime? selectedDate;
  String? selectedLevel;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    ageController.dispose();
    levelController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Hash the password using crypt package
        String hashedPassword =
            Crypt.sha256(passwordController.text.trim()).toString();

        // Create user in Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Store only profile data (with encrypted password) in Realtime Database (no plain text password)
        final userReference = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userCredential.user!.uid);

        await userReference.set({
          'fullName': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'age': ageController.text.trim(),
          'level': levelController.text.trim(),
          'dob': selectedDate != null ? selectedDate!.toIso8601String() : "",
          'password': hashedPassword, // Storing the hashed password
        });

        /////change4
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registered Successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to register: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDateOfBirth() async {
    final today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked != null) {
      selectedDate = picked;
      int age = DateTime.now().year - picked.year;
      if (DateTime.now().month < picked.month ||
          (DateTime.now().month == picked.month &&
              DateTime.now().day < picked.day)) {
        age--;
      }
      ageController.text = age.toString();
      setState(() {});
    }
  }

  // Custom Validators
  String? fullNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (!RegExp(r'^[A-Z][a-zA-Z\s]+$').hasMatch(value)) {
      return 'Full name must only contain letters and start with a capital letter';
    }
    return null;
  }

  String? ageValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    int age = int.tryParse(value) ?? 0;
    if (age <= 0) {
      return 'Age must be greater than 0';
    }
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    // Case-insensitive regex pattern to match "xxJxxxx@utas.edu.om" format
    if (!RegExp(r'\b[0-9]{2,3}[JjSs][0-9]+@utas\.edu\.om\b',
            caseSensitive: false)
        .hasMatch(value)) {
      return 'Please enter a valid email address in the format "xxJ/Sxxxx@utas.edu.om"';
    }

    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must include an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must include a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include a number';
    }
    if (!RegExp(r"[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:',.<>\/\?\\|`~]")
        .hasMatch(value)) {
      return 'Password must include a special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundLight = Color(0xFFE8EAFF);
    const Color primaryBlue = Color(0xFF293282);
    const Color mediumBlue = Color(0xFF5B70A1);
    const Color accentBlue = Color(0xFF3C5BAA);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundLight, mediumBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.person_add_alt_1, color: accentBlue, size: 100),
                  const SizedBox(height: 20),
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Register to get started",
                    style: TextStyle(color: mediumBlue, fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Full Name
                  _buildTextField(
                    fullNameController,
                    "Full Name",
                    Icons.person,
                    backgroundLight,
                    validator: fullNameValidator,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Date of Birth -> Age
                  _buildTextField(
                    ageController,
                    "Date of Birth (Age auto-calculated)",
                    Icons.cake,
                    backgroundLight,
                    readOnly: true,
                    onTap: _pickDateOfBirth,
                    validator: ageValidator,
                  ),

                  const SizedBox(height: 15),

                  // Level of Study Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.school, color: accentBlue),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      hint: const Text("Current Level of Study"),
                      items: const [
                        DropdownMenuItem(
                            value: "Foundation", child: Text("Foundation")),
                        DropdownMenuItem(
                            value: "Diploma", child: Text("Diploma")),
                        DropdownMenuItem(
                            value: "Higher Diploma",
                            child: Text("Higher Diploma")),
                        DropdownMenuItem(
                            value: "Bachelor's Degree",
                            child: Text("Bachelor's Degree")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value;
                          levelController.text = value ?? "";
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? "Please select your level"
                          : null,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Email
                  _buildTextField(
                    emailController,
                    "Email Address",
                    Icons.email,
                    backgroundLight,
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Password
                  _buildTextField(
                    passwordController,
                    "Password",
                    Icons.lock,
                    backgroundLight,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: accentBlue,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: passwordValidator,
                  ),

                  const SizedBox(height: 30),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B70A1), Color(0xFF293282)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon,
    Color fillColor, {
    bool obscureText = false,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    const Color accentBlue = Color(0xFF3C5BAA);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: accentBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: accentBlue),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}
