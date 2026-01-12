import 'package:flutter/material.dart';
import 'package:opba_app/providers/account_provider.dart';
import 'package:opba_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../utils/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction_model.dart';

class ListTransactionScreen extends StatefulWidget {
  const ListTransactionScreen({super.key});

  @override
  State<ListTransactionScreen> createState() => _ListTransactionScreenState();
}

class _ListTransactionScreenState extends State<ListTransactionScreen> {
  String? _selectedAccountId;
  bool get _isAllSelected => _selectedAccountId == null;

  void _showSelectAccountSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lütfen hesap seçiniz.'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final accountProvider = context.read<AccountProvider>();
      final authProvider = context.read<AuthProvider>();
      await accountProvider.fetchAccounts(authProvider.user?.currency);

      await context.read<TransactionProvider>().fetchTransactions(
            currency: authProvider.user?.currency,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final txProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();

    final accounts = accountProvider.accounts;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.transactions),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // account selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _AccountSelector(
              isDark: isDark,
              accounts: accounts,
              selectedAccountId: _selectedAccountId,
              isLoading: accountProvider.isLoading,
              error: accountProvider.error,
              onChanged: (id) {
                setState(() => _selectedAccountId = id);
                final authProvider = context.read<AuthProvider>();
                txProvider.fetchTransactions(
                    accountId: id, currency: authProvider.user?.currency);
              },
            ),
          ),

          // transaction ekle butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_isAllSelected) {
                    _showSelectAccountSnack(context);
                    return;
                  }
                  _showAddTransactionDialog(context);
                },
                icon: const Icon(Icons.add),
                label: Text(
                  l10n.addTransaction,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primaryBlue.withOpacity(0.35),
                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // liste
          Expanded(
            child: Builder(
              builder: (_) {
                if (txProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (txProvider.error != null) {
                  return Center(child: Text(txProvider.error!));
                }

                if (txProvider.transactions.isEmpty) {
                  return Center(child: Text(l10n.noTransactionFound));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: txProvider.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = txProvider.transactions[index];
                    return _TransactionTile(
                      transaction: tx,
                      actionsEnabled: !_isAllSelected,
                      onDisabledTap: () => _showSelectAccountSnack(context),
                      onEdit: () => _showEditTransactionDialog(context, tx),
                      onDelete: () async {
                        await context
                            .read<TransactionProvider>()
                            .deleteTransaction(tx.id!);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // transaction ekle mesajı
  void _showAddTransactionDialog(BuildContext context) {
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir hesap seçin.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddTransactionDialog(
        accountId: _selectedAccountId!,
      ),
    );
  }

  // edit transaction dialog
  void _showEditTransactionDialog(BuildContext context, Transaction tx) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditTransactionDialog(transaction: tx),
    );
  }
}

class _EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;

  const _EditTransactionDialog({
    required this.transaction,
  });

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  TransactionCategory? _selectedCategory;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;
  late DateTime _selectedDate;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.transaction.category;

    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description ?? '',
    );

    _selectedDate = widget.transaction.date;

    _selectedType = widget.transaction.type;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    final txProvider = context.read<TransactionProvider>();
    final appProvider = context.read<AppProvider>();

    final newAmount = double.tryParse(_amountController.text.trim());
    final newDesc = _descriptionController.text.trim();
    final l10n = context.l10n;

    if (_selectedCategory == null ||
        newAmount == null ||
        newAmount <= 0 ||
        newDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allFieldsRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final updatedTx = widget.transaction.copyWith(
      amount: newAmount,
      description: newDesc,
      category: _selectedCategory!,
      currency: appProvider.currency,
      date: _selectedDate,
      type: _selectedType,
    );

    final ok = await txProvider.updateTransaction(updatedTx);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşlem güncellenemedi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final l10n = context.l10n;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.editTransaction),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: l10n.category),
                items: TransactionCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(c.icon, color: c.color, size: 18),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  _DotDecimalTextInputFormatter(decimalRange: 2),
                ],
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  suffixText: appProvider.getCurrencySymbol(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                maxLines: 1,
                decoration: InputDecoration(labelText: l10n.description),
              ),
              const SizedBox(height: 16),
              _InkDateField(
                label: 'Date',
                value: _selectedDate,
                onPick: _isSubmitting
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (v) {
                        if (v != null) setState(() => _selectedType = v);
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSave,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}

class _AccountSelector extends StatelessWidget {
  final bool isDark;
  final List<dynamic> accounts;
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;

  final bool? isLoading;
  final String? error;

  const _AccountSelector({
    required this.isDark,
    required this.accounts,
    required this.selectedAccountId,
    required this.onChanged,
    this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (isLoading == true) {
      return _boxed(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (error != null) {
      return _boxed(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Text(error!, style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (accounts.isEmpty) {
      return _boxed(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Text('Hesap bulunamadı. Önce bir hesap ekleyin.'),
        ),
      );
    }

    return _boxed(
      child: DropdownButtonFormField<String>(
        value: selectedAccountId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.account,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text(
              'All',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ...accounts.map((a) {
            final id = a.id?.toString() ?? '';
            final desc = (a.description ?? '').toString().trim();

            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                desc.isEmpty ? '—' : desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _boxed({required Widget child}) {
    return Container(
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
      child: child,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool actionsEnabled;
  final VoidCallback onDisabledTap;

  const _TransactionTile({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.actionsEnabled,
    required this.onDisabledTap,
  });

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.category.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.category.icon,
              color: transaction.category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  (transaction.description ?? '').trim().isEmpty
                      ? '—'
                      : transaction.description!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark.withOpacity(0.85)
                        : AppColors.textSecondaryLight.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: transaction.isExpense
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconPillButton(
                    icon: Icons.edit,
                    tooltip: l10n.edit,
                    onTap: actionsEnabled ? onEdit : onDisabledTap,
                    isDark: isDark,
                    disabled: !actionsEnabled,
                  ),
                  const SizedBox(width: 8),
                  _IconPillButton(
                    icon: Icons.delete_outline,
                    tooltip: l10n.delete,
                    onTap: () async {
                      if (!actionsEnabled) {
                        onDisabledTap();
                        return;
                      }
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text(l10n.deleteConfirmation),
                          content: Text(l10n.deleteConfirmMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.yes),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) onDelete();
                    },
                    isDark: isDark,
                    danger: true,
                    disabled: !actionsEnabled,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;
  final bool danger;
  final bool disabled;

  const _IconPillButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
    this.danger = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withOpacity(disabled ? 0.03 : 0.06)
        : Colors.black.withOpacity(disabled ? 0.03 : 0.05);

    final fgBase =
        danger ? AppColors.error : (isDark ? Colors.white70 : Colors.black87);

    final fg = disabled ? fgBase.withOpacity(0.35) : fgBase;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: fg),
        ),
      ),
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  final String accountId;

  const _AddTransactionDialog({
    required this.accountId,
  });

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  TransactionCategory? selectedCategory;
  late final TextEditingController amountController;
  late final TextEditingController descriptionController;
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (_isSubmitting) return;

    final appProvider = context.read<AppProvider>();
    final txProvider = context.read<TransactionProvider>();

    final amount = double.tryParse(amountController.text.trim());
    final desc = descriptionController.text.trim();
    final l10n = context.l10n;

    if (selectedCategory == null ||
        amount == null ||
        amount <= 0 ||
        desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allFieldsRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final ok = await txProvider.addTransaction(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '',
        accountId: widget.accountId,
        merchant: '',
        description: desc,
        amount: amount,
        currency: appProvider.currency,
        type: _selectedType,
        category: selectedCategory!,
        date: _selectedDate,
        isRecurring: false,
      ),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşlem eklenemedi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final l10n = context.l10n;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.addTransaction),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionCategory>(
                value: selectedCategory,
                decoration: InputDecoration(labelText: l10n.category),
                items: TransactionCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(c.icon, color: c.color, size: 18),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (v) => setState(() => selectedCategory = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  _DotDecimalTextInputFormatter(decimalRange: 2),
                ],
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  suffixText: appProvider.getCurrencySymbol(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Örn: Market alışverişi',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              _InkDateField(
                label: 'Date',
                value: _selectedDate,
                onPick: _isSubmitting
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (v) {
                        if (v != null) setState(() => _selectedType = v);
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleAdd,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.add),
        ),
      ],
    );
  }
}

class _DotDecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  _DotDecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    if ('.'.allMatches(text).length > 1) return oldValue;

    final parts = text.split('.');
    if (parts.length == 2 && parts[1].length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}

class _InkDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback? onPick;

  const _InkDateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(_fmt(value)),
      ),
    );
  }
}
