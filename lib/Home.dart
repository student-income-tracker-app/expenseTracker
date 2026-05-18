import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_palette.dart';
import 'Account.dart';
import 'AddIncome.dart';
import 'AddExpense.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final Map<String, double>? testIncomes;
  final Map<String, double>? testBudgets;

  const HomePage(
      {super.key, this.onMenuTap, this.testIncomes, this.testBudgets});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _cleanupDone = false;
  Map<String, double>? _testIncomes;
  Map<String, double>? _testBudgets;

  bool get _isTestMode =>
      widget.testIncomes != null || widget.testBudgets != null;

  @override
  void initState() {
    super.initState();
    if (_isTestMode) {
      _testIncomes = {
        'Salary': 0,
        'Allowance': 0,
        ...?widget.testIncomes,
      };
      _testBudgets = {
        ...?widget.testBudgets,
      };
    } else {
      _cleanupDeprecatedCategories();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (widget.testIncomes != null || widget.testBudgets != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: _buildDashboardContent(
          palette,
          incomes: _testIncomes ?? const {},
          budgets: _testBudgets ?? const {},
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final userRef = user == null
        ? null
        : FirebaseDatabase.instance.ref('users/${user.uid}');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: StreamBuilder<DatabaseEvent>(
        stream: userRef?.onValue,
        builder: (context, snapshot) {
          final data = snapshot.data?.snapshot.value;
          final incomes = <String, double>{'Salary': 0, 'Allowance': 0};
          final budgets = <String, double>{};

          if (data is Map) {
            final map = Map<String, dynamic>.from(data);
            if (map['incomes'] is Map) {
              final incomeMap = Map<String, dynamic>.from(map['incomes']);
              for (final entry in incomeMap.values) {
                if (entry is Map) {
                  final e = Map<String, dynamic>.from(entry);
                  final source = (e['source'] ?? '').toString();
                  final amount = e['amount'];
                  if (amount is num) {
                    incomes[source] =
                        (incomes[source] ?? 0) + amount.toDouble();
                  }
                }
              }
            }

            if (map['budgets'] is Map) {
              final budgetMap = Map<String, dynamic>.from(map['budgets']);
              for (final entry in budgetMap.entries) {
                final key = entry.key.toString();
                final value = entry.value;
                if (value is num) {
                  budgets[key] = value.toDouble();
                }
              }
            }
          }

          return _buildDashboardContent(palette,
              incomes: incomes, budgets: budgets);
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    AppPalette palette, {
    required Map<String, double> incomes,
    required Map<String, double> budgets,
  }) {
    final query = _searchQuery.trim().toLowerCase();
    double displayAmount(String category) {
      return budgets[category] ?? 0.0;
    }

    final incomeItems = incomes.entries
        .map(
          (entry) => _CategoryData(
            title: entry.key,
            amount: '${entry.value.toStringAsFixed(3)} OMR',
          ),
        )
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    final defaultCategories = ['Food', 'Shopping'];
    final allCategories = <String>{
      ...defaultCategories,
      ...budgets.keys,
    }.toList()
      ..sort();

    final expenseItems = allCategories
        .map(
          (category) => _CategoryData(
            title: category,
            amount: '${displayAmount(category).toStringAsFixed(3)} OMR',
          ),
        )
        .toList();

    bool matches(_CategoryData item) {
      if (query.isEmpty) return true;
      final title = item.title.toLowerCase();
      final amount = item.amount.toLowerCase();
      return title.contains(query) || amount.contains(query);
    }

    final filteredIncome = incomeItems.where(matches).toList();
    final filteredExpense = expenseItems.where(matches).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.menu, color: palette.primary),
          onPressed: widget.onMenuTap,
        ),
        const SizedBox(height: 6),
        _buildSearchBar(
          palette,
          suggestions: () {
            final ordered = <String>[];
            void addUnique(String value) {
              if (!ordered.contains(value)) {
                ordered.add(value);
              }
            }

            for (final item in incomeItems) {
              addUnique(item.title);
            }
            for (final item in expenseItems) {
              addUnique(item.title);
            }
            return ordered;
          }(),
        ),
        const SizedBox(height: 10),
        _buildSectionTitle('Income', palette),
        const SizedBox(height: 10),
        _buildGrid(
          filteredIncome,
          palette,
          onDelete: (title) => _confirmDelete(
            context,
            onConfirm: () => _isTestMode
                ? _deleteTestIncomeSource(title)
                : _deleteIncomeSource(context, title),
          ),
          onEdit: (title) {
            final currentAmount = incomes[title] ?? 0.0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddIncomePage(
                  initialSource: title,
                  initialAmount: currentAmount,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Expense', palette),
        const SizedBox(height: 10),
        _buildGrid(
          filteredExpense,
          palette,
          onDelete: (title) => _confirmDelete(
            context,
            onConfirm: () => _isTestMode
                ? _deleteTestCategoryBudget(title)
                : _deleteCategoryBudget(context, title),
          ),
          onTap: (title) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpensePage(initialCategory: title),
              ),
            );
          },
          onEdit: (title) {
            final currentBudget = budgets[title] ?? 0.0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpensePage(
                  initialCategory: title,
                  editBudget: true,
                  initialBudget: currentBudget,
                ),
              ),
            );
          },
        ),
        if (query.isNotEmpty &&
            filteredIncome.isEmpty &&
            filteredExpense.isEmpty) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Not found',
              style: TextStyle(color: palette.primary),
            ),
          ),
        ],
        const SizedBox(height: 22),
        _buildAddActions(palette),
      ],
    );
  }

  Future<void> _deleteTestIncomeSource(String source) async {
    setState(() {
      _testIncomes?.remove(source);
    });
  }

  Future<void> _deleteTestCategoryBudget(String category) async {
    setState(() {
      _testBudgets?.remove(category);
    });
  }

  Widget _buildSearchBar(AppPalette palette,
      {required List<String> suggestions}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        String? firstCompletion(String input) {
          if (input.isEmpty) return null;
          final lower = input.toLowerCase();
          for (final option in suggestions) {
            final optionLower = option.toLowerCase();
            if (optionLower.startsWith(lower) && option.length > input.length) {
              return option;
            }
          }
          return null;
        }

        return Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: palette.inputFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.cardBorder.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              final query = textEditingValue.text.trim().toLowerCase();
              if (query.isEmpty) return const Iterable<String>.empty();
              return suggestions
                  .where((option) => option.toLowerCase().contains(query));
            },
            onSelected: (selection) {
              _searchController.text = selection;
              setState(() => _searchQuery = selection);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              _searchController.value = controller.value;
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final inlineSuggestion = firstCompletion(value.text);
                  return Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.tab &&
                          inlineSuggestion != null) {
                        controller.value = TextEditingValue(
                          text: inlineSuggestion,
                          selection: TextSelection.collapsed(
                              offset: inlineSuggestion.length),
                        );
                        setState(() => _searchQuery = inlineSuggestion);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        if (inlineSuggestion != null)
                          IgnorePointer(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 44, right: 8),
                                child: RichText(
                                  text: TextSpan(
                                    text: value.text,
                                    style: TextStyle(
                                      color: Colors.transparent,
                                      fontSize: 14,
                                      height: 1.2,
                                    ),
                                    children: [
                                      const WidgetSpan(
                                        child: SizedBox(width: 8),
                                      ),
                                      TextSpan(
                                        text: inlineSuggestion
                                            .substring(value.text.length),
                                        style: TextStyle(
                                          color:
                                              palette.primary.withOpacity(0.35),
                                          fontSize: 14,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  strutStyle: const StrutStyle(
                                      fontSize: 14, height: 1.2),
                                ),
                              ),
                            ),
                          ),
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\s]'),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.search, color: palette.primary),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String text, AppPalette palette) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: palette.primary),
    );
  }

  Widget _buildGrid(
    List<_CategoryData> items,
    AppPalette palette, {
    void Function(String title)? onDelete,
    void Function(String title)? onTap,
    void Function(String title)? onEdit,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map(
            (item) => _buildCategoryCard(
              title: item.title,
              amount: item.amount,
              palette: palette,
              onDelete: onDelete == null ? null : () => onDelete(item.title),
              onTap: onTap == null ? null : () => onTap(item.title),
              onEdit: onEdit == null ? null : () => onEdit(item.title),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String amount,
    required AppPalette palette,
    VoidCallback? onDelete,
    VoidCallback? onTap,
    VoidCallback? onEdit,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.cardFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.cardBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: palette.primary),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(fontSize: 14, color: palette.primary),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 22,
                    splashRadius: 22,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_document,
                        color: Color(0xFF2E7D32)),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 22,
                    splashRadius: 22,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Color(0xFFD64545)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategoryBudget(
      BuildContext context, String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    final budgetSnap = await userRef.child('budgets/$category').get();
    final remainingBudget = budgetSnap.value is num
        ? (budgetSnap.value as num).toDouble()
        : 0.0;
    await userRef.child('budgets/$category').remove();
    await userRef.child('overages/$category').remove();

    // Return only unspent budget. Money already spent is not refunded.
    final refund = remainingBudget > 0 ? remainingBudget : 0.0;
    if (refund > 0) {
      final netRef = userRef.child('account/netWorth');
      await netRef.runTransaction((current) {
        final currentValue = (current is num) ? current.toDouble() : 0.0;
        return Transaction.success(currentValue + refund);
      });
    }

    await reconcileNetWorth(userRef);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$category budget deleted')),
    );
  }

  Future<void> _deleteIncomeSource(BuildContext context, String source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    final incomesSnap = await userRef.child('incomes').get();
    double removedTotal = 0;
    if (incomesSnap.value is Map) {
      final incomeMap = Map<String, dynamic>.from(incomesSnap.value as Map);
      for (final entry in incomeMap.entries) {
        final value = entry.value;
        if (value is Map) {
          final e = Map<String, dynamic>.from(value);
          if ((e['source'] ?? '').toString() == source) {
            final amount = e['amount'];
            if (amount is num) removedTotal += amount.toDouble();
            await userRef.child('incomes/${entry.key}').remove();
          }
        }
      }
    }

    if (removedTotal > 0) {
      final netRef = userRef.child('account/netWorth');
      await netRef.runTransaction((current) {
        final currentValue = (current is num) ? current.toDouble() : 0.0;
        final updatedValue = currentValue - removedTotal;
        return Transaction.success(updatedValue < 0 ? 0.0 : updatedValue);
      });
    }

    await reconcileNetWorth(userRef);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$source deleted')),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required Future<void> Function() onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Do you actually want to delete it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await onConfirm();
    }
  }

  Widget _buildAddActions(AppPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpensePage()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: palette.cardBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: palette.cardFill,
            ),
            child: Text(
              'Add Expense',
              style: TextStyle(color: palette.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: palette.cardBorder, width: 2),
            color: palette.background,
          ),
          child: Icon(Icons.add, color: palette.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddIncomePage()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: palette.cardBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: palette.cardFill,
            ),
            child: Text('Add Income', style: TextStyle(color: palette.primary)),
          ),
        ),
      ],
    );
  }

  Future<void> _cleanupDeprecatedCategories() async {
    if (_cleanupDone) return;
    _cleanupDone = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
    const deprecated = ['Rent', 'Transport'];

    final budgetsSnap = await userRef.child('budgets').get();
    if (budgetsSnap.value is Map) {
      final budgetMap = Map<String, dynamic>.from(budgetsSnap.value as Map);
      for (final category in deprecated) {
        if (budgetMap.containsKey(category)) {
          await userRef.child('budgets/$category').remove();
        }
      }
    }

    final expensesSnap = await userRef.child('expenses').get();
    if (expensesSnap.value is Map) {
      final expenseMap = Map<String, dynamic>.from(expensesSnap.value as Map);
      for (final entry in expenseMap.entries) {
        final value = entry.value;
        if (value is Map) {
          final e = Map<String, dynamic>.from(value);
          final category = (e['category'] ?? '').toString();
          if (deprecated.contains(category)) {
            await userRef.child('expenses/${entry.key}').remove();
          }
        }
      }
    }

    final overageSnap = await userRef.child('overages').get();
    if (overageSnap.value is Map) {
      final overageMap = Map<String, dynamic>.from(overageSnap.value as Map);
      for (final category in deprecated) {
        if (overageMap.containsKey(category)) {
          await userRef.child('overages/$category').remove();
        }
      }
    }
  }
}

class _CategoryData {
  final String title;
  final String amount;

  const _CategoryData({required this.title, required this.amount});
}
