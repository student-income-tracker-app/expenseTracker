import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'Account.dart';
=======
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
import 'app_palette.dart';

class AddIncomePage extends StatefulWidget {
  final String? initialSource;
  final double? initialAmount;

  const AddIncomePage({super.key, this.initialSource, this.initialAmount});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceNameController = TextEditingController();
  String _source = 'Salary';
  bool _saving = false;
  String? _originalSource;

  static const List<String> _defaultSources = ['Salary', 'Allowance'];

<<<<<<< HEAD
  bool get _isEdit =>
      widget.initialSource != null && widget.initialAmount != null;
=======
  bool get _isEdit => widget.initialSource != null && widget.initialAmount != null;
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _originalSource = widget.initialSource!;
      if (_defaultSources.contains(_originalSource)) {
        _source = _originalSource!;
      } else {
        _source = 'Others';
        _sourceNameController.text = _originalSource!;
      }
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceNameController.dispose();
    super.dispose();
  }

  String _effectiveSource() {
<<<<<<< HEAD
    return _source == 'Others' ? _sourceNameController.text.trim() : _source;
=======
    return _source == 'Others'
        ? _sourceNameController.text.trim()
        : _source;
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
  }

  String? _validateAmount(String raw) {
    if (raw.isEmpty) return 'Please enter a valid amount';
    if (raw.startsWith('0') && raw.length > 1 && raw[1] != '.') {
      return 'Amount cannot start with leading zeros';
    }
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return 'Please enter a valid amount';
    return null;
  }

  String? _validateSourceName(String name) {
    if (name.isEmpty) return 'Please enter an income source';
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(name)) {
      return 'Income source must contain letters only';
    }
    return null;
  }

  Future<void> _saveIncome() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final source = _effectiveSource();
<<<<<<< HEAD
    final sourceError =
        _source == 'Others' ? _validateSourceName(source) : null;
=======
    final sourceError = _source == 'Others' ? _validateSourceName(source) : null;
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
    if (sourceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sourceError), backgroundColor: Colors.red),
      );
      return;
    }

    final rawAmount = _amountController.text.trim();
    final amountError = _validateAmount(rawAmount);
    if (amountError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(amountError), backgroundColor: Colors.red),
      );
      return;
    }
    final amount = double.parse(rawAmount);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    if (_isEdit) {
      await _updateIncome(userRef, amount, source, _originalSource ?? source);
    } else {
      final incomeRef = userRef.child('incomes').push();
      await incomeRef.set({
        'source': source,
        'amount': amount,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      final netRef = userRef.child('account/netWorth');
      await netRef.runTransaction((current) {
        final currentValue = (current is num) ? current.toDouble() : 0.0;
        return Transaction.success(currentValue + amount);
      });
    }

<<<<<<< HEAD
    await reconcileNetWorth(userRef);

=======
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  Future<void> _updateIncome(
    DatabaseReference userRef,
    double amount,
    String source,
    String originalSource,
  ) async {
    final incomesSnap = await userRef.child('incomes').get();
    double removedTotal = 0;
    if (incomesSnap.value is Map) {
      final incomeMap = Map<String, dynamic>.from(incomesSnap.value as Map);
      for (final entry in incomeMap.entries) {
        final value = entry.value;
        if (value is Map) {
          final e = Map<String, dynamic>.from(value);
          if ((e['source'] ?? '').toString() == originalSource) {
            final existing = e['amount'];
            if (existing is num) removedTotal += existing.toDouble();
            await userRef.child('incomes/${entry.key}').remove();
          }
        }
      }
    }

    if (amount > 0) {
      final incomeRef = userRef.child('incomes').push();
      await incomeRef.set({
        'source': source,
        'amount': amount,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    final delta = amount - removedTotal;
    if (delta != 0) {
      final netRef = userRef.child('account/netWorth');
      await netRef.runTransaction((current) {
        final currentValue = (current is num) ? current.toDouble() : 0.0;
<<<<<<< HEAD
        final updatedValue = currentValue + delta;
        return Transaction.success(updatedValue < 0 ? 0.0 : updatedValue);
      });
    }

    await reconcileNetWorth(userRef);
=======
        return Transaction.success(currentValue + delta);
      });
    }
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
<<<<<<< HEAD
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: palette.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'images/logo2.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  _isEdit ? 'Update Income' : 'Add Income',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: palette.primary),
                ),
                const SizedBox(height: 30),
                _buildDropdown(
                  palette: palette,
                  icon: Icons.work_outline,
                  value: _source,
                  items: const ['Salary', 'Allowance', 'Others'],
                  onChanged: (value) {
                    final next = value ?? _source;
                    setState(() => _source = next);
                    if (next != 'Others') {
                      _sourceNameController.clear();
                    }
                  },
                ),
                const SizedBox(height: 14),
                if (_source == 'Others') ...[
                  _buildTextField(
                    palette: palette,
                    hint: 'Enter Source Name',
                    controller: _sourceNameController,
                    keyboardType: TextInputType.text,
                    readOnly: false,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')),
                    ],
                    validator: (v) => _validateSourceName(v?.trim() ?? ''),
                  ),
                  const SizedBox(height: 14),
                ],
                _buildTextField(
                  palette: palette,
                  hint: 'Enter Amount',
                  controller: _amountController,
                  useCurrencyPrefix: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,3}')),
                  ],
                  validator: (v) => _validateAmount(v?.trim() ?? ''),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveIncome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.buttonFill,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _saving ? 'Saving...' : (_isEdit ? 'Update' : 'Add'),
                      style: TextStyle(
                          color: palette.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
=======
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: palette.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'images/logo2.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                _isEdit ? 'Update Income' : 'Add Income',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: palette.primary),
              ),
              const SizedBox(height: 30),
              _buildDropdown(
                palette: palette,
                icon: Icons.work_outline,
                value: _source,
                items: const ['Salary', 'Allowance', 'Others'],
                onChanged: (value) {
                  final next = value ?? _source;
                  setState(() => _source = next);
                  if (next != 'Others') {
                    _sourceNameController.clear();
                  }
                },
              ),
              const SizedBox(height: 14),
              if (_source == 'Others') ...[
                _buildTextField(
                  palette: palette,
                  hint: 'Enter Source Name',
                  controller: _sourceNameController,
                  keyboardType: TextInputType.text,
                  readOnly: false,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')),
                  ],
                  validator: (v) => _validateSourceName(v?.trim() ?? ''),
                ),
                const SizedBox(height: 14),
              ],
              _buildTextField(
                palette: palette,
                hint: 'Enter Amount',
                controller: _amountController,
                useCurrencyPrefix: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                ],
                validator: (v) => _validateAmount(v?.trim() ?? ''),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.buttonFill,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    _saving ? 'Saving...' : (_isEdit ? 'Update' : 'Add'),
                    style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required AppPalette palette,
    required String hint,
    required TextEditingController controller,
<<<<<<< HEAD
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
=======
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
    bool useCurrencyPrefix = false,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: palette.primary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.primary.withOpacity(0.6)),
        prefixIcon: useCurrencyPrefix
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Text(
                  'OMR',
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        prefixIconConstraints: useCurrencyPrefix
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
        filled: true,
        fillColor: palette.cardFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required AppPalette palette,
    required IconData icon,
    required String value,
    required List<String> items,
    ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: palette.primary),
        filled: true,
        fillColor: palette.cardFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(color: palette.primary)),
              ))
          .toList(),
    );
  }
}
<<<<<<< HEAD
=======



>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
