import 'package:flutter/material.dart';
import 'package:opba_app/models/budget_model.dart';
import 'package:opba_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  TransactionCategory? _selectedCategory;
  final _limitController = TextEditingController();
  bool _isLoading = false;

  final List<TransactionCategory> _budgetCategories = [
    TransactionCategory.market,
    TransactionCategory.food,
    TransactionCategory.entertainment,
    TransactionCategory.transport,
    TransactionCategory.bills,
    TransactionCategory.health,
    TransactionCategory.shopping,
    TransactionCategory.other,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      await context.read<BudgetProvider>().fetchBudgets(
            currency: (auth.user?.currency ?? 'TRY').toUpperCase(),
          );
    });
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _handleSetBudget() async {
    final l10n = context.l10n;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectCategory),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final limit = double.tryParse(_limitController.text);
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterValidLimit),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final auth = context.read<AuthProvider>();
    final currency = (auth.user?.currency ?? 'TRY').toUpperCase();

    final success = await budgetProvider.setBudget(
      category: _selectedCategory!,
      limitAmount: limit,
      year: budgetProvider.selectedYear,
      month: budgetProvider.selectedMonth,
      currency: currency,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      budgetProvider.fetchBudgets(currency: currency);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.budgetSavedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      _limitController.clear();
      setState(() => _selectedCategory = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final budgetProvider = Provider.of<BudgetProvider>(context);
    final auth = context.watch<AuthProvider>();
    final currency = (auth.user?.currency ?? 'TRY').toUpperCase();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.budgetManagement,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentBudgets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            if (budgetProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (budgetProvider.error != null)
              Text(budgetProvider.error!)
            else if (budgetProvider.budgets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: AppColors.textSecondaryLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noBudgetSet,
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              )
            else
              ...budgetProvider.budgets.map((budget) {
                return _buildDismissibleBudgetCard(
                  context,
                  budget: budget,
                  isDark: isDark,
                  currency: currency,
                );
              }),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.setNewBudget,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel(l10n.selectCategory),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _budgetCategories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = category);

                          final existingBudget =
                              budgetProvider.getBudgetForCategory(category);

                          if (existingBudget != null) {
                            _limitController.text =
                                existingBudget.limitAmount.toStringAsFixed(0);
                          } else {
                            _limitController.clear();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color
                                : category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: category.color,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 16,
                                color:
                                    isSelected ? Colors.white : category.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : category.color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel(l10n.setLimit),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: l10n.limitHint,
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: currency,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSetBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.approve,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context, {
    required Budget budget,
    required bool isDark,
    required String currency,
  }) {
    final progress = budget.progress;
    final percentage = budget.percentage;

    Color progressColor;
    if (percentage >= 100) {
      progressColor = AppColors.error;
    } else if (percentage >= 80) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: budget.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  budget.category.icon,
                  color: budget.category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${budget.spentAmount.toStringAsFixed(0)} / ${budget.limitAmount.toStringAsFixed(0)} $currency',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '%${percentage.toStringAsFixed(0)}',
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (progress > 1.0 ? 1.0 : progress).toDouble(),
              backgroundColor:
                  isDark ? AppColors.backgroundDark : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleBudgetCard(
    BuildContext context, {
    required Budget budget,
    required bool isDark,
    required String currency,
  }) {
    final provider = context.read<BudgetProvider>();
    final l10n = context.l10n;

    final canDelete = (budget.id != null && budget.id!.isNotEmpty);

    if (!canDelete) {
      return _buildBudgetCard(
        context,
        budget: budget,
        isDark: isDark,
        currency: currency,
      );
    }

    return Dismissible(
      key: ValueKey('budget_${budget.id}'),
      direction: DismissDirection.endToStart, // sola kaydır
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.90),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      // onay penceresi
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.deleteBudgetTitle),
                content: Text(l10n.deleteBudgetConfirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            ) ??
            false;
      },

      // UI güncellemesi
      onDismissed: (_) async {
        final auth = context.read<AuthProvider>();
        final cur = (auth.user?.currency ?? 'TRY').toUpperCase();
        final removed = budget;
        final removedIndex =
            provider.budgets.indexWhere((b) => b.id == budget.id);

        provider.budgets.removeWhere((b) => b.id == budget.id);
        provider.notifyListeners();

        final ok = await provider.deleteBudget(
          budgetId: removed.id!,
          year: provider.selectedYear,
          month: provider.selectedMonth,
          currency: cur,
        );

        if (!ok && mounted) {
          // geri ekle
          final list = provider.budgets;
          final idx = (removedIndex >= 0 && removedIndex <= list.length)
              ? removedIndex
              : list.length;
          list.insert(idx, removed);
          provider.notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Silme başarısız.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.budgetDeleted),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },

      child: _buildBudgetCard(
        context,
        budget: budget,
        isDark: isDark,
        currency: currency,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
