import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';
import 'app_palette.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();

  bool _loading = true;
  DateTime? _dob;
  Timer? _ageRefreshTimer;

  int? _calculateAgeFromDobString(String? dobValue) {
    if (dobValue == null || dobValue.trim().isEmpty) return null;
    final dob = DateTime.tryParse(dobValue.trim());
    if (dob == null) return null;

    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }

  void _updateAgeFromDob() {
    if (_dob == null) return;
    final now = DateTime.now();
    var age = now.year - _dob!.year;
    if (now.month < _dob!.month || (now.month == _dob!.month && now.day < _dob!.day)) {
      age--;
    }
    if (age >= 0) {
      _ageController.text = age.toString();
    }
  }

  void _scheduleMidnightAgeRefresh() {
    _ageRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now);
    _ageRefreshTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _updateAgeFromDob();
      });
      _scheduleMidnightAgeRefresh();
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _scheduleMidnightAgeRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!mounted) return;
      setState(() {
        _updateAgeFromDob();
      });
      _scheduleMidnightAgeRefresh();
    }
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _fullNameController.text = (data['fullName'] ?? '').toString();
      _emailController.text = (data['email'] ?? user.email ?? '').toString();
      _dob = DateTime.tryParse((data['dob'] ?? '').toString());
      final ageFromDob = _calculateAgeFromDobString(data['dob']?.toString());
      _ageController.text = ageFromDob?.toString() ?? (data['age'] ?? '').toString();
      _levelController.text = (data['level'] ?? '').toString();
    } else {
      _emailController.text = user.email ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final level = _levelController.text.trim();

    final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
    await ref.update({
      'fullName': fullName,
      'email': email,
      'level': level,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Update successful!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ageRefreshTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: palette.primary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: palette.primary),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: palette.primary))
            : SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            10 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: palette.cardFill,
                  child: Icon(Icons.person_outline, color: palette.primary, size: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  _fullNameController.text.isEmpty
                      ? 'User'
                      : _fullNameController.text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.primary),
                ),
                const SizedBox(height: 20),
                _buildField(
                  icon: Icons.person_outline,
                  controller: _fullNameController,
                  hint: 'Full name',
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')),
                  ],
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Please enter your full name';
                    if (!RegExp(r'^[A-Z][a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Full name must only contain letters and start with a capital letter';
                    }
                    return null;
                  },
                ),
                _buildField(
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Please enter your email address';
                    if (!RegExp(r'\b[0-9]{2,3}[JjSs][0-9]+@utas\.edu\.om\b', caseSensitive: false)
                        .hasMatch(value)) {
                      return 'Please enter a valid UTAS email';
                    }
                    return null;
                  },
                ),
                _buildField(
                  icon: Icons.cake_outlined,
                  controller: _ageController,
                  hint: 'Age (from registration)',
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                // ONLY this part was updated (value fix)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<String>(
                    value: [
                      "Foundation",
                      "Diploma",
                      "Higher Diploma",
                      "Bachelor's Degree"
                    ].contains(_levelController.text.trim())
                        ? _levelController.text.trim()
                        : null,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please select your level' : null,
                    onChanged: (value) {
                      setState(() {
                        _levelController.text = value ?? '';
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: "Foundation", child: Text("Foundation")),
                      DropdownMenuItem(value: "Diploma", child: Text("Diploma")),
                      DropdownMenuItem(value: "Higher Diploma", child: Text("Higher Diploma")),
                      DropdownMenuItem(value: "Bachelor's Degree", child: Text("Bachelor's Degree")),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.school_outlined, color: AppPalette.of(context).primary),
                      hintText: 'Level',
                      hintStyle: TextStyle(
                        color: AppPalette.of(context).primary.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: AppPalette.of(context).inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.buttonFill,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Update Profile'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(color: palette.primary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: palette.primary),
          hintText: hint,
          hintStyle: TextStyle(color: palette.primary.withOpacity(0.6)),
          filled: true,
          fillColor: palette.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

