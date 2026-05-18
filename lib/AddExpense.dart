import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';
import 'app_settings.dart';
import 'notifications_helper.dart';

<<<<<<< HEAD
double calculateRemainingBudget(double currentBudget, double expenseAmount) {
  return currentBudget - expenseAmount;
}

bool shouldShowBudgetCloseReminder({
  required double originalBudget,
  required double remainingBudget,
}) {
  if (originalBudget <= 0 || remainingBudget <= 0) return false;
  return remainingBudget <= originalBudget * 0.10;
}

double totalIncomeFromUserData(dynamic userData) {
  if (userData is! Map) return 0;
  final map = Map<String, dynamic>.from(userData);
  if (map['incomes'] is! Map) return 0;

  final incomeMap = Map<String, dynamic>.from(map['incomes']);
  var total = 0.0;
  for (final entry in incomeMap.values) {
    if (entry is Map) {
      final income = Map<String, dynamic>.from(entry);
      final amount = income['amount'];
      if (amount is num && amount > 0) {
        total += amount.toDouble();
      }
    }
  }
  return total;
}

=======
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
class AddExpensePage extends StatefulWidget {
  final String? initialCategory;
  final bool editBudget;
  final double? initialBudget;

  const AddExpensePage({
    super.key,
    this.initialCategory,
    this.editBudget = false,
    this.initialBudget,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _category = 'Food';
  bool _showCategoryPicker = true;
  bool _showBudgetForm = true;
  DateTime? _selectedDate;
  bool _saving = false;
  static const List<String> _defaultCategories = ['Food', 'Shopping'];
<<<<<<< HEAD
  bool _isAfterToday(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    return selectedDay.isAfter(today);
  }
=======
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0

  String? _validateAmount(String raw) {
    if (raw.isEmpty) return 'Please enter a valid amount';
    if (raw.startsWith('0') && raw.length > 1 && raw[1] != '.') {
      return 'Amount cannot start with leading zeros';
    }
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return 'Please enter a valid amount';
    return null;
  }

  String? _validateCategoryName(String name) {
    if (name.isEmpty) return 'Please enter a category name';
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(name)) {
      return 'Category name must contain letters only';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.editBudget &&
        widget.initialCategory != null &&
        widget.initialCategory!.isNotEmpty) {
      final initial = widget.initialCategory!;
      _showBudgetForm = true;
      if (_defaultCategories.contains(initial)) {
        _category = initial;
        _showCategoryPicker = false;
        _categoryNameController.text = initial;
      } else {
        _category = 'Others';
        _showCategoryPicker = true;
        _categoryNameController.text = initial;
      }
      if (widget.initialBudget != null) {
        _budgetController.text = widget.initialBudget!.toStringAsFixed(2);
      }
      return;
    }

    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _category = widget.initialCategory!;
      _showBudgetForm = false;
      _showCategoryPicker = false;
      _categoryNameController.text = _category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _categoryNameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_showBudgetForm) {
      final categoryName = _category == 'Others'
          ? _categoryNameController.text.trim()
          : _category;
<<<<<<< HEAD
      final categoryError =
          _category == 'Others' ? _validateCategoryName(categoryName) : null;
=======
      final categoryError = _category == 'Others' ? _validateCategoryName(categoryName) : null;
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
      final rawBudget = _budgetController.text.trim();
      final budgetError = _validateAmount(rawBudget);
      if (categoryError != null || budgetError != null) {
        return;
      }
      final budget = double.parse(rawBudget);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() => _saving = true);
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      final budgetRef = userRef.child('budgets/$categoryName');
      final prevSnap = await budgetRef.get();
      final prevBudget =
          prevSnap.value is num ? (prevSnap.value as num).toDouble() : 0.0;
      final delta = budget - prevBudget;

      if (delta > 0) {
        final netSnap = await userRef.child('account/netWorth').get();
        final netWorth =
            netSnap.value is num ? (netSnap.value as num).toDouble() : 0.0;
        if (netWorth < delta) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough balance to set this budget'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      await budgetRef.set(budget);

      if (delta != 0) {
        final netRef = userRef.child('account/netWorth');
        await netRef.runTransaction((current) {
          final currentValue = (current is num) ? current.toDouble() : 0.0;
          return Transaction.success(currentValue - delta);
        });
      }

      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context);
      return;
    }

    final rawAmount = _amountController.text.trim();
    final amountError = _validateAmount(rawAmount);
    if (amountError != null) return;
    if (_selectedDate == null) return;
<<<<<<< HEAD
    final now = DateTime.now();
    if (_isAfterToday(_selectedDate!, now)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Future dates are not allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
=======
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
    final amount = double.parse(rawAmount);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

<<<<<<< HEAD
    final userSnap = await userRef.get();
    if (totalIncomeFromUserData(userSnap.value) <= 0) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add income first'),
          backgroundColor: Colors.red,
        ),
=======
    final netSnap = await userRef.child('account/netWorth').get();
    final netWorth = netSnap.value is num ? (netSnap.value as num).toDouble() : 0.0;
    if (netWorth <= 0 || netWorth < amount) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough balance'), backgroundColor: Colors.red),
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
      );
      return;
    }

    final budgetRef = userRef.child('budgets/$_category');
    final budgetSnap = await budgetRef.get();
    double? remainingBudget;
<<<<<<< HEAD
    double? originalBudget;
    if (budgetSnap.exists && budgetSnap.value is num) {
      final currentBudget = (budgetSnap.value as num).toDouble();
      originalBudget = currentBudget;
=======
    if (budgetSnap.exists && budgetSnap.value is num) {
      final currentBudget = (budgetSnap.value as num).toDouble();
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
      if (currentBudget <= 0) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
          const SnackBar(
              content: Text('Budget ended'), backgroundColor: Colors.red),
=======
          const SnackBar(content: Text('Please set a budget first'), backgroundColor: Colors.red),
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
        );
        return;
      }
      if (currentBudget < amount) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
          const SnackBar(
              content: Text('Not enough budget for this category'),
              backgroundColor: Colors.red),
        );
        return;
      }
      remainingBudget = calculateRemainingBudget(currentBudget, amount);
=======
          const SnackBar(content: Text('Not enough budget for this category'), backgroundColor: Colors.red),
        );
        return;
      }
      remainingBudget = currentBudget - amount;
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
      await budgetRef.set(remainingBudget);
    } else {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(
            content: Text('Please set a budget first'),
            backgroundColor: Colors.red),
=======
        const SnackBar(content: Text('Please set a budget first'), backgroundColor: Colors.red),
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
      );
      return;
    }

    final expenseRef = userRef.child('expenses').push();
    await expenseRef.set({
      'category': _category,
      'amount': amount,
      'createdAt': _selectedDate!.millisecondsSinceEpoch,
    });

    if (AppSettings.instance.notificationsEnabled) {
      await NotificationHelper.showNotification(
        title: 'Expense Recorded',
        body:
            '$_category: -${amount.toStringAsFixed(2)} OMR. Remaining ${remainingBudget.toStringAsFixed(2)} OMR.',
      );
      if (remainingBudget <= 0) {
        await NotificationHelper.showNotification(
          title: 'Budget Ended',
          body: '$_category budget has ended.',
        );
<<<<<<< HEAD
      } else if (shouldShowBudgetCloseReminder(
        originalBudget: originalBudget,
        remainingBudget: remainingBudget,
      )) {
=======
      } else if (remainingBudget <= 1) {
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
        await NotificationHelper.showNotification(
          title: 'Budget Alert',
          body: '$_category spending is close to the limit.',
        );
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
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
                  _showBudgetForm
                      ? (widget.editBudget ? 'Update Expense' : 'Add Expense')
                      : _category,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: palette.primary),
                ),
                const SizedBox(height: 30),
                if (_showBudgetForm) ...[
                  if (_showCategoryPicker) ...[
                    _buildDropdown(
                      palette: palette,
                      icon: Icons.account_balance_wallet,
                      value: _category,
                      items: const ['Food', 'Shopping', 'Others'],
                      onChanged: (value) {
                        final selected = value ?? _category;
                        final previous = _category;
                        setState(() => _category = selected);
                        if (selected != 'Others') {
                          _categoryNameController.text = selected;
                        } else if (previous != 'Others') {
                          _categoryNameController.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    _buildTextField(
                      palette: palette,
                      icon: Icons.account_balance_wallet,
                      hint: 'Category',
                      controller: _categoryNameController,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_category == 'Others' && _showCategoryPicker) ...[
                    _buildTextField(
                      palette: palette,
                      icon: Icons.edit_note,
                      hint: 'Enter Category Name',
                      controller: _categoryNameController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z\s]')),
                      ],
                      validator: (v) => _validateCategoryName(v?.trim() ?? ''),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _buildTextField(
                    palette: palette,
                    hint: 'Enter Budget Amount',
                    controller: _budgetController,
                    useCurrencyPrefix: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,3}')),
                    ],
                    validator: (v) => _validateAmount(v?.trim() ?? ''),
                  ),
                ] else ...[
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
                  const SizedBox(height: 14),
                  _buildDateField(
                    palette: palette,
                    icon: Icons.event,
                    hint: 'Enter Date',
                    controller: _dateController,
                    validator: (v) =>
                        _selectedDate == null ? 'Please select a date' : null,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.buttonFill,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _saving
                          ? 'Saving...'
                          : (widget.editBudget ? 'Update' : 'Add'),
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
                _showBudgetForm
                    ? (widget.editBudget ? 'Update Expense' : 'Add Expense')
                    : _category,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: palette.primary),
              ),
              const SizedBox(height: 30),
              if (_showBudgetForm) ...[
                if (_showCategoryPicker) ...[
                  _buildDropdown(
                    palette: palette,
                    icon: Icons.account_balance_wallet,
                    value: _category,
                    items: const ['Food', 'Shopping', 'Others'],
                    onChanged: (value) {
                      final selected = value ?? _category;
                      final previous = _category;
                      setState(() => _category = selected);
                      if (selected != 'Others') {
                        _categoryNameController.text = selected;
                      } else if (previous != 'Others') {
                        _categoryNameController.clear();
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  _buildTextField(
                    palette: palette,
                    icon: Icons.account_balance_wallet,
                    hint: 'Category',
                    controller: _categoryNameController,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                  ),
                  const SizedBox(height: 14),
                ],
                if (_category == 'Others' && _showCategoryPicker) ...[
                  _buildTextField(
                    palette: palette,
                    icon: Icons.edit_note,
                    hint: 'Enter Category Name',
                    controller: _categoryNameController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')),
                    ],
                    validator: (v) => _validateCategoryName(v?.trim() ?? ''),
                  ),
                  const SizedBox(height: 14),
                ],
                _buildTextField(
                  palette: palette,
                  hint: 'Enter Budget Amount',
                  controller: _budgetController,
                  useCurrencyPrefix: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                  ],
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter valid data'; // ✅ matches test
                      }
                      return null;
                    },
                ),
              ] else ...[
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
                const SizedBox(height: 14),
                _buildDateField(
                  palette: palette,
                  icon: Icons.event,
                  hint: 'Enter Date',
                  controller: _dateController,
                  validator: (v) => _selectedDate == null ? 'Please select a date' : null,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.buttonFill,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    _saving
                        ? 'Saving...'
                        : (widget.editBudget ? 'Update' : 'Add'),
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

  Widget _buildDropdown({
    required AppPalette palette,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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

  Widget _buildTextField({
    required AppPalette palette,
    IconData? icon,
    required String hint,
    required TextEditingController controller,
<<<<<<< HEAD
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
=======
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
    bool readOnly = false,
    bool useCurrencyPrefix = false,
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
            : (icon == null ? null : Icon(icon, color: palette.primary)),
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

  Widget _buildDateField({
    required AppPalette palette,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: palette.primary),
      validator: validator,
      onTap: () async {
        final now = DateTime.now();
<<<<<<< HEAD
        final today = DateTime(now.year, now.month, now.day);
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? today,
          firstDate: DateTime(2000),
          lastDate: today,
        );
        if (picked != null) {
          if (_isAfterToday(picked, now)) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Future dates are not allowed'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
=======
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: now,
        );
        if (picked != null) {
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
          setState(() => _selectedDate = picked);
          controller.text = '${picked.day}/${picked.month}/${picked.year}';
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.primary.withOpacity(0.6)),
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
    );
  }
}
<<<<<<< HEAD
=======

>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
