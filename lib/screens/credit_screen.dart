// credit_screen.dart
import 'package:flutter/material.dart';
import 'package:opba_app/models/loan_rate_model.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/loan_provider.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  int _currentIndex = 2;

  // Banka renkleri (mock'tan uyarlanmış). Backend renk göndermediği için burada map'liyoruz.
  static const Map<String, Color> _bankColors = {
    'Halkbank': Color(0xFF0066B3),
    'Vakıfbank': Color(0xFF003366),
    'Ziraat Bankası': Color(0xFF1A5F2A),
    'İş Bankası': Color(0xFF0A4D92),
    'Akbank': Color(0xFFE30613),
    'Garanti BBVA': Color(0xFF006A4D),
    'Yapı Kredi': Color(0xFF004A8F),
    'QNB Finansbank': Color(0xFF6F2C91),
  };

  Color _colorForBank(String bankName) {
    return _bankColors[bankName] ?? AppColors.primaryBlue;
  }

  @override
  void initState() {
    super.initState();

    // Ekran açılır açılmaz faizleri çek
    Future.microtask(() async {
      // İstersen burada AuthProvider/AppProvider'dan currency alıp gönderebilirsin
      // final currency = context.read<AuthProvider>().user?.currency ?? 'TRY';
      const currency = 'TRY';

      await context.read<LoanProvider>().fetchRates(
            loanType: 'consumer',
            currency: currency,
            sort: 'asc',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final loanProvider = context.watch<LoanProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.creditComparison,
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
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // bilgi kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGradientStart,
                    AppColors.primaryGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.personalLoanRatesTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.personalLoanRatesDesc,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // bölüm başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bankInterestRates,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.bestRate,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // RATE LIST STATE
            if (loanProvider.isLoadingRates)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (loanProvider.errorRates != null)
              _ErrorBox(
                message: loanProvider.errorRates!,
                onRetry: () async {
                  const currency = 'TRY';
                  await context.read<LoanProvider>().fetchRates(
                        loanType: 'consumer',
                        currency: currency,
                        sort: 'asc',
                      );
                },
              )
            else if (loanProvider.rates.isEmpty)
              const _InfoBox(
                message: l10n.creditRateNotFound,
              )
            else ...[
              // kredi faiz oranları listesi
              ...loanProvider.rates.map((r) {
                final best = loanProvider.bestRate;
                final isBest = best != null &&
                    r.bankName == best.bankName &&
                    r.currency == best.currency &&
                    r.loanType == best.loanType &&
                    r.termMonths == best.termMonths;

                return _buildLoanRateCard(
                  context,
                  bankName: r.bankName,
                  interestRate: r.monthlyRatePercent,
                  termMonths: r.termMonths,
                  color: _colorForBank(r.bankName),
                  isBest: isBest,
                  isDark: isDark,
                );
              }),
            ],

            const SizedBox(height: 24),

            // hesaplama butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: (loanProvider.bestRate == null)
                    ? null
                    : () {
                        _showCalculatorBottomSheet(context);
                      },
                icon: const Icon(Icons.calculate),
                label: Text(l10n.loanCalculator),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
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

  Widget _buildLoanRateCard(
    BuildContext context, {
    required String bankName,
    required double interestRate, // monthlyRatePercent
    required Color color,
    required bool isBest,
    required bool isDark,
    required int termMonths,
  }) {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBest ? Border.all(color: AppColors.success, width: 2) : null,
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
          // banka ikonu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // banka ismi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.personalLoan,
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

          // faiz oranı
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (isBest)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.best,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    '%${interestRate.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isBest ? AppColors.success : null,
                    ),
                  ),
                ],
              ),
              Text(
                '$termMonths ${l10n.months} • ${l10n.monthlyInterest}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCalculatorBottomSheet(BuildContext context) {
    final l10n = context.l10n;

    final amountController = TextEditingController();
    final termController = TextEditingController(text: '12');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final loanProvider = context.watch<LoanProvider>();
            final best = loanProvider.bestRate;

            Future<void> calculate() async {
              if (best == null) return;

              final amount = double.tryParse(amountController.text.trim());
              final term = int.tryParse(termController.text.trim());

              if (amount == null || term == null || amount <= 0 || term <= 0) {
                // geçersiz input: mevcut sonucu silmek istemiyorsan dokunma
                return;
              }

              final input = LoanCalcInput(
                bankName: best.bankName,
                loanType: best.loanType,
                currency: best.currency,
                termMonths: term,
                principal: amount,
              );

              await context.read<LoanProvider>().calculate(input);
            }

            final calcRes = loanProvider.calcResponse;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.loanCalculator,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.loanAmount,
                      hintText: l10n.amountHint,
                      suffixText: best?.currency ?? 'TRY',
                    ),
                    onChanged: (_) => calculate(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: termController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.loanTermMonths,
                      hintText: l10n.termHint,
                      suffixText: l10n.months,
                    ),
                    onChanged: (_) => calculate(),
                  ),
                  const SizedBox(height: 18),
                  if (loanProvider.isCalculating)
                    const Center(child: CircularProgressIndicator())
                  else if (loanProvider.calcError != null)
                    _ErrorInline(message: loanProvider.calcError!)
                  else if (calcRes != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _kvRow(
                            left: l10n.installmentMonthly,
                            right:
                                '${calcRes.result.monthlyPayment.toStringAsFixed(2)} ${best?.currency ?? 'TRY'}',
                            rightBold: true,
                          ),
                          const SizedBox(height: 8),
                          _kvRow(
                            left: l10n.totalPayment,
                            right:
                                '${calcRes.result.totalPayment.toStringAsFixed(2)} ${best?.currency ?? 'TRY'}',
                          ),
                          const SizedBox(height: 8),
                          _kvRow(
                            left: l10n.totalInterest,
                            right:
                                '${calcRes.result.totalInterest.toStringAsFixed(2)} ${best?.currency ?? 'TRY'}',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _kvRow({
    required String left,
    required String right,
    bool rightBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left),
        Text(
          right,
          style: TextStyle(
            fontWeight: rightBold ? FontWeight.bold : FontWeight.w600,
            fontSize: rightBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/expenses');
        break;
      case 2:
        // zaten kredili
        break;
    }
  }
}

// -------------------
// Small UI helpers
// -------------------
class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
              label: const Text(
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
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String message;
  const _InfoBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorInline extends StatelessWidget {
  final String message;
  const _ErrorInline({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
