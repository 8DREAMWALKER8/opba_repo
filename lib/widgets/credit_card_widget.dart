import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class CreditCardWidget extends StatelessWidget {
  final Account account;

  const CreditCardWidget({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // kart tipi
          const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          // kart numarası
          Text(
            account.maskedCardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          // kart detayları satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // kart sahibi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.cardHolderName ?? 'Kart Sahibi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // son kullanma tarihi
              Text(
                account.expiryDate ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // bakiye
          Text(
            'Bakiye: ${_formatNumber(account.balance)} TL',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    final bankName = account.bankName.toLowerCase();
    if (bankName.contains('ziraat')) {
      return [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)];
    } else if (bankName.contains('iş') || bankName.contains('is')) {
      return [const Color(0xFF1E40AF), const Color(0xFF60A5FA)];
    } else if (bankName.contains('garanti')) {
      return [const Color(0xFF065F46), const Color(0xFF10B981)];
    } else if (bankName.contains('yapı') || bankName.contains('yapi')) {
      return [const Color(0xFF1E3A8A), const Color(0xFF6366F1)];
    } else if (bankName.contains('akbank')) {
      return [const Color(0xFFDC2626), const Color(0xFFF87171)];
    } else {
      return [const Color(0xFF374151), const Color(0xFF6B7280)];
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class MiniCreditCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const MiniCreditCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '**** ${account.lastFourDigits}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${account.balance.toStringAsFixed(0)} TL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
