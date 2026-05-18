import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_palette.dart';
import 'Recommendation.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        'Summary',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: palette.primary),
                      ),
                      const SizedBox(height: 18),
                      StreamBuilder<DatabaseEvent>(
                        stream: userRef?.onValue,
                        builder: (context, snapshot) {
                          final totals = <String, double>{};
                          final activeCategories = <String>{};
                          final now = DateTime.now();
                          final currentMonthStart =
                              DateTime(now.year, now.month, 1);
                          final nextMonthStart =
                              DateTime(now.year, now.month + 1, 1);
                          final value = snapshot.data?.snapshot.value;
                          if (value is Map) {
                            final map = Map<String, dynamic>.from(value);
                            if (map['budgets'] is Map) {
                              final budgetMap =
                                  Map<String, dynamic>.from(map['budgets']);
                              activeCategories.addAll(
                                budgetMap.keys.map((key) => key.toString()),
                              );
                              for (final category in activeCategories) {
                                totals.putIfAbsent(category, () => 0.0);
                              }
                            }
                            if (map['expenses'] is Map &&
                                activeCategories.isNotEmpty) {
                              final expenseMap =
                                  Map<String, dynamic>.from(map['expenses']);
                              for (final entry in expenseMap.values) {
                                if (entry is Map) {
                                  final e = Map<String, dynamic>.from(entry);
                                  final category =
                                      (e['category'] ?? '').toString();
                                  if (!activeCategories.contains(category)) {
                                    continue;
                                  }
                                  final amount = e['amount'];
                                  final createdAt = e['createdAt'];
                                  if (amount is num && createdAt is int) {
                                    final date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            createdAt);
                                    if (date.isBefore(nextMonthStart) &&
                                        !date.isBefore(currentMonthStart)) {
                                      final expenseValue = amount.toDouble();
                                      totals[category] =
                                          (totals[category] ?? 0) +
                                              expenseValue;
                                    }
                                  }
                                }
                              }
                            }
                          }

                          if (totals.isEmpty) {
                            return Column(
                              children: [
                                _buildEmptyChart(palette),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: 180,
                                  height: 40,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RecommendationPage(
                                            message:
                                                'No spending data yet. Start tracking your expenses to get personalized tips.',
                                            predictionCategory: '',
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: palette.cardFill,
                                      side:
                                          BorderSide(color: palette.cardBorder),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Recommendation',
                                      style:
                                          TextStyle(color: palette.primary),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          final topEntry = totals.entries.reduce(
                            (a, b) => a.value >= b.value ? a : b,
                          );
                          final recommendation = _buildRecommendationMessage(
                            topEntry,
                          );
                          return Column(
                            children: [
                              _buildChart(palette, totals),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: 180,
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RecommendationPage(
                                          message: recommendation,
                                          predictionCategory: topEntry.value > 0
                                              ? topEntry.key
                                              : '',
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: palette.cardFill,
                                    side: BorderSide(color: palette.cardBorder),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text('Recommendation',
                                      style: TextStyle(color: palette.primary)),
                                ),
                              ),
                            ],
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

  Widget _buildEmptyChart(AppPalette palette) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: palette.cardFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'No categories to display.\nAdd a category budget from Home.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: palette.primary.withOpacity(0.8),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildChart(AppPalette palette, Map<String, double> totals) {
    final labels = totals.keys.toList()..sort();
    final values = labels.map((key) => totals[key] ?? 0).toList();
    final maxValue = values.fold<double>(0, (max, v) => v > max ? v : max);
    final chartMax = _niceMax(maxValue);
    const chartHeight = 220.0;
    const yTicks = 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: palette.cardFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 1,
        maxScale: 2.5,
        child: SizedBox(
          height: chartHeight + 34,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildYAxis(palette, chartMax, yTicks),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    _buildGridLines(palette, chartHeight, yTicks),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(labels.length, (index) {
                          final value = values[index];
                          final label = labels[index];
                          return _bar(
                            palette,
                            _scaledHeight(value, chartMax, chartHeight),
                            value,
                            label,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(AppPalette palette, double height, double value, String label) {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(color: palette.primary, fontSize: 9),
          ),
          const SizedBox(height: 2),
          Container(
            width: 22,
            height: height,
            decoration: BoxDecoration(
              color: palette.buttonFill,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: palette.primary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _scaledHeight(double value, double maxValue, double maxHeight) {
    if (maxValue <= 0) return 8;
    final ratio = value / maxValue;
    return 8 + ratio * (maxHeight - 16);
  }

  double _niceMax(double value) {
    if (value <= 0) return 10;
    final magnitude = value.toStringAsFixed(0).length;
    final base = pow10(magnitude - 1);
    return ((value / base).ceil() * base).toDouble();
  }

  int pow10(int exp) {
    int result = 1;
    for (var i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }

  Widget _buildYAxis(AppPalette palette, double maxValue, int ticks) {
    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          ticks + 1,
          (index) {
            final value = (maxValue / ticks) * (ticks - index);
            return Text(
              value.toStringAsFixed(0),
              style: TextStyle(color: palette.primary, fontSize: 10),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridLines(AppPalette palette, double height, int ticks) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        ticks + 1,
        (index) => Container(
          height: 1,
          color: palette.primary.withOpacity(0.15),
        ),
      ),
    );
  }

  String _buildRecommendationMessage(
    MapEntry<String, double> topEntry,
  ) {
    if (topEntry.value == 0) {
      return 'No spending data yet. Start tracking your expenses to get personalized tips.';
    }
    final category = topEntry.key.toLowerCase();
    return 'Your $category spending is the highest this month. '
        'Try to set a clear limit and track every purchase to stay within your budget.';
  }
}
