import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  int _currentIndex = 2;

  // demo kredi faiz oranları
  final List<Map<String, dynamic>> _loanRates = [
    {
      'bankName': 'Halkbank',
      'bankCode': 'halkbank',
      'interestRate': 3.89,
      'color': const Color(0xFF0066B3),
      'isBest': true,
    },
    {
      'bankName': 'Vakıfbank',
      'bankCode': 'vakifbank',
      'interestRate': 3.95,
      'color': const Color(0xFF003366),
      'isBest': false,
    },
    {
      'bankName': 'Ziraat Bankası',
      'bankCode': 'ziraat',
      'interestRate': 3.99,
      'color': const Color(0xFF1A5F2A),
      'isBest': false,
    },
    {
      'bankName': 'İş Bankası',
      'bankCode': 'isbank',
      'interestRate': 4.09,
      'color': const Color(0xFF0A4D92),
      'isBest': false,
    },
    {
      'bankName': 'Akbank',
      'bankCode': 'akbank',
      'interestRate': 4.15,
      'color': const Color(0xFFE30613),
      'isBest': false,
    },
    {
      'bankName': 'Garanti BBVA',
      'bankCode': 'garanti',
      'interestRate': 4.19,
      'color': const Color(0xFF006A4D),
      'isBest': false,
    },
    {
      'bankName': 'Yapı Kredi',
      'bankCode': 'yapikredi',
      'interestRate': 4.29,
      'color': const Color(0xFF004A8F),
      'isBest': false,
    },
    {
      'bankName': 'QNB Finansbank',
      'bankCode': 'qnb',
      'interestRate': 4.39,
      'color': const Color(0xFF6F2C91),
      'isBest': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

            // kredi faiz oranları listesi
            ..._loanRates.map((rate) {
              return _buildLoanRateCard(
                context,
                bankName: rate['bankName'],
                interestRate: (rate['interestRate'] as num).toDouble(),
                color: rate['color'],
                isBest: rate['isBest'],
                isDark: isDark,
              );
            }),

            const SizedBox(height: 24),

            // hesaplama butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
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
    required double interestRate,
    required Color color,
    required bool isBest,
    required bool isDark,
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
                l10n.monthlyInterest,
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
    double? monthlyPayment;
    double? totalPayment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void calculate() {
              final amount = double.tryParse(amountController.text);
              final term = int.tryParse(termController.text);

              if (amount != null && term != null && amount > 0 && term > 0) {
                // en düşük faiz oranı ile hesaplama
                final rate =
                    (_loanRates.first['interestRate'] as num).toDouble() / 100;
                final n = term;
                final monthly = (amount * rate * _pow(1 + rate, n)) /
                    (_pow(1 + rate, n) - 1);

                setModalState(() {
                  monthlyPayment = monthly;
                  totalPayment = monthly * n;
                });
              }
            }

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
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.loanAmount,
                      hintText: '100000',
                      suffixText: 'TL',
                    ),
                    onChanged: (_) => calculate(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: termController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.loanTermMonths,
                      hintText: '12',
                      suffixText: l10n.months,
                    ),
                    onChanged: (_) => calculate(),
                  ),
                  const SizedBox(height: 24),
                  if (monthlyPayment != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.installmentMonthly,
                              ),
                              Text(
                                '${monthlyPayment!.toStringAsFixed(2)} TL',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.totalPayment,
                              ),
                              Text(
                                '${totalPayment!.toStringAsFixed(2)} TL',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
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
