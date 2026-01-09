import 'package:flutter/material.dart';
import 'package:opba_app/providers/account_provider.dart';
import 'package:opba_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final accountProvider = context.read<AccountProvider>();
      final authProvider = context.read<AuthProvider>();
      // 1) Accounts'ı çek
      await accountProvider.fetchAccounts(authProvider.user?.currency);

      // 2) İlk account id
      final accounts = accountProvider.accounts;
      final firstAccountId = accounts.isNotEmpty ? accounts.first.id : null;

      // 3) Transactions'ı ilk account'a göre çek
      await context.read<TransactionProvider>().fetchTransactions(
            accountId: firstAccountId,
            currency: authProvider.user?.currency,
          );

      // 4) Screen state’inde de seçimi tutuyorsan set et
      if (mounted &&
          firstAccountId != null &&
          firstAccountId.toString().isNotEmpty) {
        setState(() => _selectedAccountId = firstAccountId.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final txProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();

    final accounts = accountProvider.accounts;

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      final firstId = accounts.first.id?.toString();
      if (firstId != null && firstId.isNotEmpty) {
        _selectedAccountId = firstId;
      }
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ ACCOUNT SELECTOR (EN ÜST) - SADECE DESCRIPTION
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
                // İstersen seçilen account'a göre tx filtreleme:
                // context.read<TransactionProvider>().fetchTransactions(accountId: id);
              },
            ),
          ),

          // ✅ ADD TRANSACTION BUTONU
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_selectedAccountId == null)
                    ? null
                    : () => _showAddTransactionDialog(context),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Transaction',
                  style: TextStyle(fontWeight: FontWeight.w600),
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

          // ✅ LISTE
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
                  return const Center(child: Text('Henüz işlem yok.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: txProvider.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = txProvider.transactions[index];
                    return _TransactionTile(
                      transaction: tx,
                      onEdit: () => _showEditTransactionDialog(context, tx),
                      onDelete: () async {
                        // Burayı gerçek delete’e bağlayalım:
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

  // ===========================
  // ADD TRANSACTION DIALOG
  // ===========================
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

  // ===========================
  // EDIT TRANSACTION DIALOG (STUB)
  // ===========================
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

    if (_selectedCategory == null ||
        newAmount == null ||
        newAmount <= 0 ||
        newDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kategori, miktar ve açıklamayı girin.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ✅ Güncellenmiş transaction (copyWith varsa kullan)
    final updatedTx = widget.transaction.copyWith(
      amount: newAmount,
      description: newDesc,
      category: _selectedCategory!,
      currency: appProvider.currency, // istersen değiştirme
      date: DateTime.now(), // occurredAt güncellenecekse
    );

    // ✅ Provider’da update fonksiyonun yoksa şimdilik false dönebilir
    // Örnek: await txProvider.updateTransaction(updatedTx);
    final ok = await txProvider.updateTransaction(updatedTx); // bunu yazacağız

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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Transaction'),
      content: SingleChildScrollView(
        // ✅ keyboard + küçük ekran overflow fix
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
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
                decoration: InputDecoration(
                  labelText: 'Amount',
                  suffixText: appProvider.getCurrencySymbol(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSave,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ===========================
// ACCOUNT SELECTOR (SADECE DESCRIPTION)
// ===========================
class _AccountSelector extends StatelessWidget {
  final bool isDark;
  final List<dynamic> accounts; // İstersen List<Account> yap
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
        decoration: const InputDecoration(
          labelText: 'Account',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: accounts.map((a) {
          final id = a.id?.toString() ?? '';
          final desc = (a.description ?? '').toString().trim();

          return DropdownMenuItem(
            value: id,
            child: Text(
              desc.isEmpty ? '—' : desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
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

// ===========================
// TRANSACTION TILE (EDIT + DELETE)
// ===========================
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  (transaction.description ?? '').trim().isEmpty
                      ? '—'
                      : transaction.description!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // SAĞ BLOK: TUTAR + AKSİYONLAR
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

              // ✅ Daha şık edit + delete
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconPillButton(
                    icon: Icons.edit,
                    tooltip: 'Edit',
                    onTap: onEdit,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _IconPillButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text('Silme Onayı'),
                          content:
                              const Text('Silmek istediğinize emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Vazgeç'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Evet'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        onDelete();
                      }
                    },
                    isDark: isDark,
                    danger: true,
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

  const _IconPillButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);
    final fg =
        danger ? AppColors.error : (isDark ? Colors.white70 : Colors.black87);

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

    if (selectedCategory == null ||
        amount == null ||
        amount <= 0 ||
        desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kategori, miktar ve açıklamayı girin.'),
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
        type: TransactionType.expense,
        category: selectedCategory!,
        date: DateTime.now(),
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        // ✅ keyboard + küçük ekran overflow fix
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
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
                decoration: InputDecoration(
                  labelText: 'Amount',
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
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleAdd,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
