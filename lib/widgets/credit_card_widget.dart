import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';
import '../screens/edit_account_screen.dart';

class CreditCardWidget extends StatefulWidget {
  final Account account;
  final String currency;

  const CreditCardWidget({
    super.key,
    required this.account,
    required this.currency,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
  bool _showFullCardNumber = false;

  static const double _actionColWidth = 44;

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final currency = widget.currency;
    final rawCardNumber = (account.cardNumber ?? '').trim();

    final cardText = _showFullCardNumber
        ? _formatCardNumber(rawCardNumber)
        : _maskCardNumber(rawCardNumber);

    final description = (account.description ?? '').trim();
    final descriptionText = description.isEmpty ? '—' : description;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(account),
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
          // description + edit ikonu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  descriptionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: _actionColWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditAccountScreen(account: account),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // card number + göz ikonu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  cardText.isEmpty ? '—' : cardText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _showFullCardNumber ? 14 : 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: _actionColWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(
                        () => _showFullCardNumber = !_showFullCardNumber),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _showFullCardNumber
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // kart sahibi adı
          Text(
            (account.cardHolderName ?? '').trim().isEmpty
                ? 'Kart Sahibi'
                : account.cardHolderName!.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // bakiye
          Text(
            'Bakiye: ${_formatNumber(account.balance)} ${currency}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(Account account) {
    final bankName = account.bankName.toLowerCase();
    if (bankName.contains('iş') || bankName.contains('is')) {
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

  String _formatCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != digits.length) buffer.write(' ');
    }
    return buffer.toString();
  }

  String _maskCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.length < 8) return digits;

    final start = digits.substring(0, 4);
    final end = digits.substring(digits.length - 4);
    return '$start **** **** $end';
  }
}
