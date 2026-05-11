import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_palette.dart';
import 'DetailedStatement.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'images/logo2.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Report',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: palette.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DetailedStatementPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.buttonFill,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Detailed Statement',
                            style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: palette.primary),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<DatabaseEvent>(
                        stream: userRef?.onValue,
                        builder: (context, snapshot) {
                          final value = snapshot.data?.snapshot.value;
                          final items = <_ReportEntry>[];
                          if (value is Map) {
                            final map = Map<String, dynamic>.from(value);
                            if (map['expenses'] is Map) {
                              final expenseMap = Map<String, dynamic>.from(map['expenses']);
                              for (final entry in expenseMap.values) {
                                if (entry is Map) {
                                  final e = Map<String, dynamic>.from(entry);
                                  final category = (e['category'] ?? '').toString();
                                  final amount = e['amount'];
                                  final createdAt = e['createdAt'];
                                  if (amount is num) {
                                    final date = createdAt is int
                                        ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                                        : DateTime.now();
                                    items.add(_ReportEntry(
                                      title: category,
                                      amount: amount.toDouble(),
                                      date: date,
                                      type: _TransactionType.expense,
                                    ));
                                  }
                                }
                              }
                            }
                            if (map['incomes'] is Map) {
                              final incomeMap = Map<String, dynamic>.from(map['incomes']);
                              for (final entry in incomeMap.values) {
                                if (entry is Map) {
                                  final e = Map<String, dynamic>.from(entry);
                                  final source = (e['source'] ?? '').toString();
                                  final amount = e['amount'];
                                  final createdAt = e['createdAt'];
                                  if (amount is num) {
                                    final date = createdAt is int
                                        ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                                        : DateTime.now();
                                    items.add(_ReportEntry(
                                      title: source,
                                      amount: amount.toDouble(),
                                      date: date,
                                      type: _TransactionType.income,
                                    ));
                                  }
                                }
                              }
                            }
                          }
                          items.sort((a, b) => b.date.compareTo(a.date));
                          final visible = items;
                          if (visible.isEmpty) {
                            return Text('No transactions yet.', style: TextStyle(color: palette.primary));
                          }
                          return Column(
                            children: visible
                                .map(
                                  (entry) => _ReportItem(
                                    title: entry.title,
                                    date: _formatDate(entry.date),
                                    amount: entry.type == _TransactionType.expense
                                        ? '-${entry.amount.toStringAsFixed(2)} OMR'
                                        : '+${entry.amount.toStringAsFixed(2)} OMR',
                                    isIncome: entry.type == _TransactionType.income,
                                    palette: palette,
                                  ),
                                )
                                .toList(),
                          );
                        },
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

class _ReportEntry {
  final String title;
  final double amount;
  final DateTime date;
  final _TransactionType type;

  const _ReportEntry({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

enum _TransactionType { income, expense }

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _ReportItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isIncome;
  final AppPalette palette;

  const _ReportItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(date, style: TextStyle(color: palette.primary, fontSize: 12)),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC43A3A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

