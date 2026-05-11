import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_palette.dart';

class DetailedStatementPage extends StatefulWidget {
  const DetailedStatementPage({super.key});

  @override
  State<DetailedStatementPage> createState() => _DetailedStatementPageState();
}

class _DetailedStatementPageState extends State<DetailedStatementPage> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late DateTime _activeFromDate;
  late DateTime _activeToDate;
  bool _sortNewestFirst = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate.subtract(const Duration(days: 30));
    _activeToDate = _toDate;
    _activeFromDate = _fromDate;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: _toDate,
    );
    if (picked != null) {
      setState(() => _fromDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _toDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _applySearch() {
    setState(() {
      _activeFromDate = _fromDate;
      _activeToDate = _toDate;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    DatabaseReference? userRef;
    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      }
    }
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.primary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Detailed Statement',
          style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: palette.cardFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.cardBorder.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search and download all your statements by date range',
                      style: TextStyle(
                        color: palette.primary.withOpacity(0.75),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: 'Date from',
                            value: _formatDateInput(_fromDate),
                            onTap: _pickFromDate,
                            palette: palette,
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateField(
                            label: 'Date to',
                            value: _formatDateInput(_toDate),
                            onTap: _pickToDate,
                            palette: palette,
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _applySearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE24A4A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      text: 'You will be able to search for a maximum of 3 months transactions at a given time.',
                      palette: palette,
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      text: 'You can change the dates and search again in 3 months periods.',
                      palette: palette,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: palette.primary),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.cardFill,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: palette.cardBorder.withOpacity(0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SortChip(
                        label: 'Newest',
                        selected: _sortNewestFirst,
                        onTap: () => setState(() => _sortNewestFirst = true),
                        palette: palette,
                      ),
                      const SizedBox(width: 6),
                      _SortChip(
                        label: 'Oldest',
                        selected: !_sortNewestFirst,
                        onTap: () => setState(() => _sortNewestFirst = false),
                        palette: palette,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: !_hasSearched
                    ? Center(
                        child: Text(
                          'Choose a date range and tap Search.',
                          style: TextStyle(color: palette.primary.withOpacity(0.7)),
                        ),
                      )
                    : StreamBuilder<DatabaseEvent>(
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
                          final fromKey = _dateKey(_activeFromDate);
                          final toKey = _dateKey(_activeToDate);
                          final visible = items
                              .where((entry) {
                                final entryKey = _dateKey(entry.date);
                                return entryKey >= fromKey && entryKey <= toKey;
                              })
                              .toList()
                            ..sort(
                              (a, b) => _sortNewestFirst
                                  ? b.date.compareTo(a.date)
                                  : a.date.compareTo(b.date),
                            );
                          if (visible.isEmpty) {
                            return Center(
                              child: Text('No transactions found.', style: TextStyle(color: palette.primary)),
                            );
                          }
                          return ListView(
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
              ),
            ],
          ),
        ),
      ),
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

int _dateKey(DateTime date) {
  return (date.year * 10000) + (date.month * 100) + date.day;
}

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

String _formatDateInput(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
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

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final AppPalette palette;
  final IconData icon;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.palette,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.cardBorder.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: palette.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 11, color: palette.primary.withOpacity(0.7))),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(color: palette.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String text;
  final AppPalette palette;

  const _InfoRow({required this.text, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 14, color: palette.primary.withOpacity(0.5)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: palette.primary.withOpacity(0.6), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppPalette palette;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.buttonFill : palette.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.cardBorder.withOpacity(0.6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: palette.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
