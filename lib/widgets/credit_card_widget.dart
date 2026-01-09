import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class CreditCardWidget extends StatefulWidget {
  final Account account;

  const CreditCardWidget({
    super.key,
    required this.account,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
  bool _showFullIban = false;

  // ✅ Sağ taraftaki ikon kolonunun sabit genişliği (üst ve alt satır aynı hizaya gelsin)
  static const double _actionColWidth = 44;

  @override
  Widget build(BuildContext context) {
    final account = widget.account;

    final ibanText =
        _showFullIban ? _formatIban(account.iban) : _maskIban(account.iban);

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
          // ✅ ÜST SATIR: Description (sol) + Edit (sağ) -> aynı hizada
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ dikey merkez
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
                width: _actionColWidth, // ✅ sabit kolon
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      // TODO: edit event (şimdilik boş)
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

          // ✅ ALT SATIR: IBAN (sol) + Göz (sağ) -> Edit ile tam aynı hizada
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ dikey merkez
            children: [
              Expanded(
                child: Text(
                  ibanText.isEmpty ? '—' : ibanText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _showFullIban ? 14 : 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: _showFullIban ? 0.6 : 1.2,
                    height: 1.2,
                  ),
                  maxLines: _showFullIban ? 2 : 1,
                  overflow: _showFullIban
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: _actionColWidth, // ✅ üst satır ile aynı kolon
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _showFullIban = !_showFullIban),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _showFullIban ? Icons.visibility_off : Icons.visibility,
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

          // hesap adı
          Row(
            children: [
              Expanded(
                child: Text(
                  account.cardHolderName ?? 'Hesap Adı',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // bakiye
          Text(
            'Bakiye: ${_formatNumber(account.balance)} ${account.currency}',
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

  String _formatIban(String iban) {
    final raw = iban.replaceAll(' ', '').trim();
    if (raw.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      buffer.write(raw[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != raw.length) buffer.write(' ');
    }
    return buffer.toString();
  }

  String _maskIban(String iban) {
    final raw = iban.replaceAll(' ', '').trim();
    if (raw.isEmpty) return '';
    if (raw.length <= 8) return raw;

    final start = raw.substring(0, 4);
    final end = raw.substring(raw.length - 4);
    return '$start **** **** **** **** $end';
  }
}
