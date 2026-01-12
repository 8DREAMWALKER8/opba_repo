import 'package:flutter/material.dart';
import 'package:opba_app/providers/auth_provider.dart';
import 'package:opba_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/credit_card_widget.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final accountProvider = context.read<AccountProvider>();
      final transactionProvider = context.read<TransactionProvider>();
      final authProvider = context.read<AuthProvider>();
      await accountProvider.fetchAccounts(authProvider.user?.currency);
      await transactionProvider.fetchTransactions(
          currency: authProvider.user?.currency);
      context.read<NotificationProvider>().startPolling();
    });
  }

  Future<void> _refreshData() async {
    final accountProvider = context.read<AccountProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final authProvider = context.read<AuthProvider>();

    await Future.wait([
      accountProvider.fetchAccounts(authProvider.user?.currency),
      transactionProvider.fetchTransactions(
          currency: authProvider.user?.currency),
    ]);
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountProvider = Provider.of<AccountProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = context.read<AuthProvider>();
    final userCurrency = authProvider.user?.currency;

    String currencySymbol(String code) {
      switch (code) {
        case 'USD':
          return '\$';
        case 'EUR':
          return '€';
        case 'GBP':
          return '£';
        case 'TRY':
        default:
          return '₺';
      }
    }

    final isPrefix =
        userCurrency == 'USD' || userCurrency == 'EUR' || userCurrency == 'GBP';

    final symbol = currencySymbol(userCurrency!);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.accounts,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: isDark ? Colors.white : AppColors.primaryBlue,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings').then((_) async {
                final accountProvider = context.read<AccountProvider>();
                final transactionProvider = context.read<TransactionProvider>();
                final authProvider = context.read<AuthProvider>();
                await accountProvider
                    .fetchAccounts(authProvider.user?.currency);
                await transactionProvider.fetchTransactions(
                    currency: authProvider.user?.currency);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.accounts,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-account');
                  },
                  child: Text(
                    l10n.addNewAccount,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // hesap kartları
            if (accountProvider.accounts.isEmpty)
              Container(
                width: double.infinity,
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
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.noAccountsAvailable,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...accountProvider.accounts.map((account) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CreditCardWidget(
                      account: account, currency: userCurrency),
                );
              }),

            const SizedBox(height: 8),

            // toplam bakiye
            if (accountProvider.accounts.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.totalBalance,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      isPrefix
                          ? '$symbol${_formatNumber(accountProvider.totalBalance)}'
                          : '${_formatNumber(accountProvider.totalBalance)} $symbol',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // son işlemler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentTransactions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.description_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, '/transactions')
                        .then((_) async {
                      final authProvider = context.read<AuthProvider>();

                      await context
                          .read<TransactionProvider>()
                          .fetchTransactions(
                            currency: authProvider.user?.currency,
                          );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // işlem durumu yönetimi
            if (transactionProvider.isLoading)
              Container(
                width: double.infinity,
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
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.transactionsLoading,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else if (transactionProvider.error != null)
              Container(
                width: double.infinity,
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
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            transactionProvider.error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _refreshData();
                        },
                        icon: const Icon(Icons.refresh,
                            color: AppColors.primaryBlue),
                        label: Text(
                          l10n.tryAgain,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (transactionProvider.recentTransactions.isEmpty)
              Container(
                width: double.infinity,
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
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.noRecentTransactions,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _refreshData();
                        },
                        icon: const Icon(Icons.refresh,
                            color: AppColors.primaryBlue),
                        label: Text(
                          l10n.refresh,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...transactionProvider.recentTransactions.map((transaction) {
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
                          color: transaction.category.color.withOpacity(0.1),
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
                            // kategori adı
                            Text(
                              transaction.category.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 2),

                            // açıklama
                            Text(
                              (transaction.description ?? '').trim().isEmpty
                                  ? '—'
                                  : transaction.description!.trim(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isPrefix
                                ? '$symbol${_formatNumber(transaction.amount)}'
                                : '${_formatNumber(transaction.amount)} $symbol',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: transaction.isExpense
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          Text(
                            _formatDate(transaction.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigateToScreen(index);
        },
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        // zaten ana sayfada
        break;
      case 1:
        Navigator.pushNamed(context, '/expenses');
        break;
      case 2:
        Navigator.pushNamed(context, '/credit');
        break;
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
