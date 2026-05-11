import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_palette.dart';
import 'AddIncome.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userRef = user == null ? null : FirebaseDatabase.instance.ref('users/${user.uid}');

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
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: palette.primary),
                      ),
                      const SizedBox(height: 22),
                      StreamBuilder<DatabaseEvent>(
                        stream: userRef?.onValue,
                        builder: (context, snapshot) {
                          final value = snapshot.data?.snapshot.value;
                          double totalIncome = 0.0;
                          double totalExpense = 0.0;
                          if (value is Map) {
                            final map = Map<String, dynamic>.from(value);
                            if (map['incomes'] is Map) {
                              final incomeMap = Map<String, dynamic>.from(map['incomes']);
                              for (final entry in incomeMap.values) {
                                if (entry is Map) {
                                  final e = Map<String, dynamic>.from(entry);
                                  final amount = _toDouble(e['amount']);
                                  if (amount != null) totalIncome += amount.abs();
                                }
                              }
                            }
                            if (map['expenses'] is Map) {
                              final expenseMap = Map<String, dynamic>.from(map['expenses']);
                              for (final entry in expenseMap.values) {
                                if (entry is Map) {
                                  final e = Map<String, dynamic>.from(entry);
                                  final amount = _toDouble(e['amount']);
                                  if (amount != null) totalExpense += amount.abs();
                                }
                              }
                            }
                          }

                          final savings = totalIncome - totalExpense;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                            decoration: BoxDecoration(
                              color: palette.buttonFill,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text('Net Worth', style: TextStyle(color: palette.primary, fontSize: 14)),
                                const SizedBox(height: 8),
                                Text(
                                  '${savings.toStringAsFixed(3)} OMR',
                                  style: TextStyle(color: palette.primary, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: palette.cardFill,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _SummaryRow(
                                        label: 'Income',
                                        value: '+${totalIncome.toStringAsFixed(3)} OMR',
                                        color: const Color(0xFF2E7D32),
                                      ),
                                      const Divider(height: 16),
                                      _SummaryRow(
                                        label: 'Expenses',
                                        value: '-${totalExpense.toStringAsFixed(3)} OMR',
                                        color: const Color(0xFFC43A3A),
                                      ),
                                      const Divider(height: 16),
                                      _SummaryRow(
                                        label: 'Savings',
                                        value: '${savings.toStringAsFixed(3)} OMR',
                                        color: palette.primary,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Savings = Income - Expenses',
                                  style: TextStyle(color: palette.primary.withOpacity(0.7), fontSize: 11),
                                ),
                                const SizedBox(height: 14),
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
                              MaterialPageRoute(builder: (_) => const AddIncomePage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: palette.cardFill,
                            side: BorderSide(color: palette.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Add Amount', style: TextStyle(color: palette.primary)),
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
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}


