import 'package:flutter/material.dart';
import 'package:opba_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();

      // 3) Transactions'ı ilk account'a göre çek
      await context.read<TransactionProvider>().fetchTransactions(
            currency: authProvider.user?.currency,
          );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final auth = context.watch<AuthProvider>();
    final userCurrency = (auth.user?.currency ?? 'TRY').toUpperCase();

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

    final symbol = currencySymbol(userCurrency);
    final categorySummaries = transactionProvider.categorySummaries;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.expenses,
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
                // geri dönüldüğünde bu ekranı yenile
                final authProvider = context.read<AuthProvider>();

                await context.read<TransactionProvider>().fetchTransactions(
                      currency: authProvider.user?.currency,
                    );
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
            // toplam giderler kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  Text(
                    l10n.translate('total_expenses'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPrefix
                        ? '$symbol${_formatNumber(transactionProvider.totalExpenses)}'
                        : '${_formatNumber(transactionProvider.totalExpenses)} $symbol',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.translate('this_month'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // pasta grafiği
            if (categorySummaries.isNotEmpty) ...[
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Center(
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: PieChartPainter(
                          categories: categorySummaries,
                          animationValue: _animation.value,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ] else
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 64,
                      color: AppColors.textSecondaryLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('no_expense_data'),
                      style:
                          const TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),

            // kategori açıklaması
            Text(
              l10n.translate('categories_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            ...categorySummaries.map((summary) {
              return _buildCategoryItem(
                context,
                category: summary.category,
                amount: summary.amount,
                percentage: summary.percentage,
                currencySymbol: 'TL',
              );
            }),

            const SizedBox(height: 24),

            // tüm işlemler butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/transactions').then((_) async {
                    // geri dönüldüğünde bu ekranı yenile
                    final authProvider = context.read<AuthProvider>();

                    await context.read<TransactionProvider>().fetchTransactions(
                          currency: authProvider.user?.currency,
                        );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.allTransactions,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // bütçe yönetim butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/budget').then((_) async {
                    // geri dönüldüğünde bu ekranı yenile
                    final authProvider = context.read<AuthProvider>();

                    await context.read<TransactionProvider>().fetchTransactions(
                          currency: authProvider.user?.currency,
                        );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  l10n.budgetManagement,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  Widget _buildCategoryItem(
    BuildContext context, {
    required TransactionCategory category,
    required double amount,
    required double percentage,
    required String currencySymbol,
  }) {
    final auth = context.watch<AuthProvider>();
    final userCurrency = (auth.user?.currency ?? 'TRY').toUpperCase();

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

    final symbol = currencySymbol(userCurrency);

    final isPrefix =
        userCurrency == 'USD' || userCurrency == 'EUR' || userCurrency == 'GBP';
    final l10n = context.l10n;
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
          // renk göstergesi
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // kategori ismi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.localizedName(l10n),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '%${percentage.toStringAsFixed(1)}',
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
          // miktar
          Text(
            isPrefix
                ? '$symbol${_formatNumber(amount)}'
                : '${_formatNumber(amount)} $symbol',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // masraflar zaten dahil
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/credit');
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

// özel pasta grafiği çizimi
class PieChartPainter extends CustomPainter {
  final List<CategorySummary> categories;
  final double animationValue;
  final bool isDark;

  PieChartPainter({
    required this.categories,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    if (categories.length == 1) {
      final c = categories.first;

      final outerPaint = Paint()
        ..color = c.category.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, outerPaint);

      final innerPaint = Paint()
        ..color = isDark ? AppColors.backgroundDark : Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, innerRadius - 5, innerPaint);
      return;
    }

    double startAngle = -math.pi / 2;

    for (var category in categories) {
      final sweepAngle =
          (category.percentage / 100) * 2 * math.pi * animationValue;

      final paint = Paint()
        ..color = category.category.color
        ..style = PaintingStyle.fill;

      // yay çizimi
      final path = Path()
        ..moveTo(
          center.dx + innerRadius * math.cos(startAngle),
          center.dy + innerRadius * math.sin(startAngle),
        )
        ..lineTo(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(
          center.dx + innerRadius * math.cos(startAngle + sweepAngle),
          center.dy + innerRadius * math.sin(startAngle + sweepAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + sweepAngle,
          -sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // beyaz ayırıcı çizgi ekle
      if (categories.length > 1 && sweepAngle > 0) {
        final separatorPaint = Paint()
          ..color = isDark ? AppColors.backgroundDark : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawLine(
          Offset(
            center.dx + innerRadius * math.cos(startAngle),
            center.dy + innerRadius * math.sin(startAngle),
          ),
          Offset(
            center.dx + radius * math.cos(startAngle),
            center.dy + radius * math.sin(startAngle),
          ),
          separatorPaint,
        );
      }

      startAngle += sweepAngle;
    }

    // iç daireyi çiz
    final innerCirclePaint = Paint()
      ..color = isDark ? AppColors.backgroundDark : Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius - 5, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
