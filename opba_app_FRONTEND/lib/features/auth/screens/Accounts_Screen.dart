import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';

/// Hesaplar Ekranı - Banka kartları ve son işlemler
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final PageController _cardController = PageController(viewportFraction: 0.9);
  int _currentCardIndex = 0;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black87),
          onPressed: () {
            // Ana sayfaya git
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          'Hesaplar',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              // Menu action
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hesaplar Başlığı ve Yeni Hesap Butonu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hesaplar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showAddAccountDialog();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('YENİ HESAP EKLE +'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4A7FD8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Banka Kartları Carousel
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _cardController,
              onPageChanged: (index) {
                setState(() {
                  _currentCardIndex = index;
                });
              },
              itemCount: _mockAccounts.length,
              itemBuilder: (context, index) {
                return _buildBankCard(_mockAccounts[index]);
              },
            ),
          ),

          // Sayfa Göstergesi
          const SizedBox(height: 16),
          _buildPageIndicator(),

          const SizedBox(height: 24),

          // Son İşlemler Başlığı
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Son İşlemler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Son İşlemler Listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockTransactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(_mockTransactions[index]);
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Banka Kartı Widget'ı
  Widget _buildBankCard(BankAccount account) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: account.gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: account.gradientColors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kart Tipi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account.cardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Icon(
                  account.icon,
                  color: Colors.white.withOpacity(0.8),
                  size: 32,
                ),
              ],
            ),

            const Spacer(),

            // Kart Numarası
            Text(
              _formatCardNumber(account.cardNumber),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 16),

            // İsim ve Tarih
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account.holderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  account.expiryDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Sayfa Göstergesi
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_mockAccounts.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentCardIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentCardIndex == index
                ? const Color(0xFF4A7FD8)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  /// İşlem Öğesi
  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // İkon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.icon,
              color: transaction.iconColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Tutar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Ana Sayfa', false),
              _buildNavItem(Icons.account_balance_wallet, 'Hesaplar', true),
              _buildNavItem(Icons.receipt_long, 'İşlemler', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF4A7FD8) : Colors.grey.shade400,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? const Color(0xFF4A7FD8) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Hesap Ekleme Dialog'u
  void _showAddAccountDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni Hesap Ekle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildBankOption('Ziraat Bankası', Icons.account_balance),
              _buildBankOption('İş Bankası', Icons.account_balance),
              _buildBankOption('Garanti BBVA', Icons.account_balance),
              _buildBankOption('Akbank', Icons.account_balance),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankOption(String bankName, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A7FD8)),
      title: Text(bankName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$bankName hesabı ekleniyor...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  String _formatCardNumber(String number) {
    return number.replaceAllMapped(
      RegExp(r'.{4}'),
      (match) => '${match.group(0)} ',
    ).trim();
  }
}

// ============================================================================
// MODEL SINIFLAR
// ============================================================================

class BankAccount {
  final String cardType;
  final String cardNumber;
  final String holderName;
  final String expiryDate;
  final List<Color> gradientColors;
  final IconData icon;

  BankAccount({
    required this.cardType,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.gradientColors,
    required this.icon,
  });
}

class Transaction {
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

// ============================================================================
// MOCK DATA
// ============================================================================

final List<BankAccount> _mockAccounts = [
  BankAccount(
    cardType: 'VISA',
    cardNumber: '8843234769126940',
    holderName: 'Ahmet Yılmaz',
    expiryDate: '06/25',
    gradientColors: [
      const Color(0xFF7B88F4),
      const Color(0xFF5B6FD8),
    ],
    icon: Icons.credit_card,
  ),
  BankAccount(
    cardType: 'MASTERCARD',
    cardNumber: '5421123456789012',
    holderName: 'Ayşe Demir',
    expiryDate: '12/26',
    gradientColors: [
      const Color(0xFFFF6B6B),
      const Color(0xFFEE5A6F),
    ],
    icon: Icons.credit_card,
  ),
  BankAccount(
    cardType: 'TROY',
    cardNumber: '9792123456789012',
    holderName: 'Mehmet Kaya',
    expiryDate: '03/27',
    gradientColors: [
      const Color(0xFF4ECDC4),
      const Color(0xFF44A08D),
    ],
    icon: Icons.credit_card,
  ),
];

final List<Transaction> _mockTransactions = [
  Transaction(
    title: 'Sony Playstation',
    subtitle: 'PSN Store Game',
    amount: '-33.80 TL',
    date: '16 Kasım 2022',
    isIncome: false,
    icon: Icons.sports_esports,
    iconColor: Colors.black87,
    iconBgColor: Colors.grey.shade100,
  ),
  Transaction(
    title: 'Para Transfer',
    subtitle: 'Ahmet\'e gönderildi',
    amount: '+2650 TL',
    date: '14 Kasım 2022',
    isIncome: true,
    icon: Icons.account_balance,
    iconColor: Colors.green,
    iconBgColor: Colors.green.shade50,
  ),
  Transaction(
    title: 'Kahve Dükkanı',
    subtitle: 'Starbucks Coffee',
    amount: '-90 TL',
    date: '12 Kasım 2022',
    isIncome: false,
    icon: Icons.local_cafe,
    iconColor: Colors.brown,
    iconBgColor: Colors.brown.shade50,
  ),
  Transaction(
    title: 'Market',
    subtitle: 'Migros Alışverişi',
    amount: '-450 TL',
    date: '10 Kasım 2022',
    isIncome: false,
    icon: Icons.shopping_cart,
    iconColor: Colors.orange,
    iconBgColor: Colors.orange.shade50,
  ),
  Transaction(
    title: 'Maaş',
    subtitle: 'Şirket ödemesi',
    amount: '+15000 TL',
    date: '01 Kasım 2022',
    isIncome: true,
    icon: Icons.attach_money,
    iconColor: Colors.green,
    iconBgColor: Colors.green.shade50,
  ),
];