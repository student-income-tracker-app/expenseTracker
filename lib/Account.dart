import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_palette.dart';
import 'AddExpense.dart';
import 'AddIncome.dart';

double calculatePaymentBalance(double totalIncome, double totalExpense) {
  final balance = totalIncome - totalExpense;
  return balance < 0 ? 0 : balance;
}

/// Current balance left in each category (decreases when you spend).
double totalBudgetFromUserData(dynamic userData) {
  if (userData is! Map) return 0;
  final map = Map<String, dynamic>.from(userData);
  if (map['budgets'] is! Map) return 0;

  final budgetMap = Map<String, dynamic>.from(map['budgets']);
  var total = 0.0;
  for (final amount in budgetMap.values) {
    final budget = _toDouble(amount);
    if (budget != null && budget > 0) {
      total += budget;
    }
  }
  return total;
}

double totalExpenseFromUserData(dynamic userData) {
  if (userData is! Map) return 0;
  final map = Map<String, dynamic>.from(userData);
  if (map['expenses'] is! Map) return 0;

  final expenseMap = Map<String, dynamic>.from(map['expenses']);
  var total = 0.0;
  for (final entry in expenseMap.values) {
    if (entry is Map) {
      final e = Map<String, dynamic>.from(entry);
      final amount = _toDouble(e['amount']);
      if (amount != null) total += amount.abs();
    }
  }
  return total;
}

/// Unallocated balance (reduced when budgets are set, increased on income/delete).
double netWorthFromUserData(dynamic userData) {
  if (userData is! Map) return 0;
  final map = Map<String, dynamic>.from(userData);
  if (map['account'] is! Map) return 0;
  final account = Map<String, dynamic>.from(map['account']);
  final net = _toDouble(account['netWorth']);
  if (net == null) return 0;
  return net < 0 ? 0 : net;
}

bool hasNoIncomeOrBudget(dynamic userData) {
  return totalIncomeFromUserData(userData) <= 0 &&
      totalBudgetFromUserData(userData) <= 0;
}

/// Whether any category budget entry exists (even if currently 0 after spending).
bool hasBudgetCategories(dynamic userData) {
  if (userData is! Map) return false;
  final map = Map<String, dynamic>.from(userData);
  if (map['budgets'] is! Map) return false;
  return Map<String, dynamic>.from(map['budgets']).isNotEmpty;
}

/// Money you still have.
/// - No budget: equals total income (expenses are history only).
/// - With budget: unallocated net worth + remaining category budgets.
///   Spending lowers the budget; old expense records do not reduce this again.
double totalAvailableFromUserData(dynamic userData) {
  if (hasNoIncomeOrBudget(userData)) return 0;

  final budgets = totalBudgetFromUserData(userData);
  if (budgets > 0 || hasBudgetCategories(userData)) {
    return netWorthFromUserData(userData) + budgets;
  }
  return totalIncomeFromUserData(userData);
}

/// Fixes stale net worth without re-applying old expense records.
Future<void> reconcileNetWorth(DatabaseReference userRef) async {
  final snap = await userRef.get();
  final value = snap.value;
  if (hasNoIncomeOrBudget(value)) {
    await userRef.child('account/netWorth').set(0);
    return;
  }
  // Only sync when there is income but no category has been set up yet.
  if (totalBudgetFromUserData(value) <= 0 && !hasBudgetCategories(value)) {
    await userRef.child('account/netWorth').set(
          totalIncomeFromUserData(value),
        );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      reconcileNetWorth(
        FirebaseDatabase.instance.ref('users/${user.uid}'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userRef = user == null
        ? null
        : FirebaseDatabase.instance.ref('users/${user.uid}');

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/logo2.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payment',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: palette.primary),
                      ),
                      const SizedBox(height: 22),
                      StreamBuilder<DatabaseEvent>(
                        stream: userRef?.onValue,
                        builder: (context, snapshot) {
                          final value = snapshot.data?.snapshot.value;
                          final totalIncome = totalIncomeFromUserData(value);
                          final totalExpense = totalExpenseFromUserData(value);

                          final totalBudget = totalBudgetFromUserData(value);
                          final totalAvailable =
                              totalAvailableFromUserData(value);
                          final savings = totalAvailable;
                          final displayNetWorth = totalAvailable;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 22),
                            decoration: BoxDecoration(
                              color: palette.buttonFill,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text('Net Worth',
                                    style: TextStyle(
                                        color: palette.primary, fontSize: 14)),
                                const SizedBox(height: 8),
                                Text(
                                  '${displayNetWorth.toStringAsFixed(3)} OMR',
                                  style: TextStyle(
                                      color: palette.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: palette.cardFill,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _SummaryRow(
                                        label: 'Income',
                                        value:
                                            '+${totalIncome.toStringAsFixed(3)} OMR',
                                        color: const Color(0xFF2E7D32),
                                      ),
                                      const Divider(height: 16),
                                      _SummaryRow(
                                        label: 'Expenses',
                                        value:
                                            '-${totalExpense.toStringAsFixed(3)} OMR',
                                        color: const Color(0xFFC43A3A),
                                      ),
                                      const Divider(height: 16),
                                      _SummaryRow(
                                        label: 'Savings',
                                        value:
                                            '${savings.toStringAsFixed(3)} OMR',
                                        color: palette.primary,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  totalBudget > 0
                                      ? 'Savings = unallocated + category budgets'
                                      : 'Savings = total income entered',
                                  style: TextStyle(
                                      color: palette.primary
                                          .withValues(alpha: 0.7),
                                      fontSize: 11),
                                ),
                                const SizedBox(height: 14),
                                _BudgetInfoBox(
                                  label: 'Total Budget',
                                  value:
                                      '${totalBudget.toStringAsFixed(3)} OMR',
                                  palette: palette,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 140,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddIncomePage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: palette.cardFill,
                            side: BorderSide(color: palette.cardBorder),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Add Amount',
                              style: TextStyle(color: palette.primary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BudgetInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final AppPalette palette;

  const _BudgetInfoBox({
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: palette.cardFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}
