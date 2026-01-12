import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opba_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  static const double _fieldGap = 20;

  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _balanceController = TextEditingController();

  String? _selectedBank;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _descriptionController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  String _cleanCardNumber(String v) => v.replaceAll(' ', '').trim();

  Future<void> _handleSubmit() async {
    final l10n = context.l10n;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectBank),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

    final cardNumber = _cleanCardNumber(_cardNumberController.text);
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    final success = await accountProvider.addAccount(
      bankName: _selectedBank!,
      cardHolderName: _cardHolderController.text.trim(),
      cardNumber: cardNumber,
      description: _descriptionController.text.trim(),
      balance: balance,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountAddedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.addAccount,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // banka seç
              _buildLabel(l10n.bankSelect),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedBank,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  hint: Text(l10n.bankSelect),
                  items: Bank.turkishBanks.map((bank) {
                    return DropdownMenuItem(
                      value: bank.name,
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance,
                              color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(bank.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBank = value),
                ),
              ),

              const SizedBox(height: _fieldGap),

              // kart numarası
              _buildLabel(l10n.cardNumber),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _CardNumberFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: l10n.accountNumberHint,
                  prefixIcon: const Icon(Icons.credit_card),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  counterText: '',
                ),
                maxLength: 19,
                validator: (value) {
                  final v = _cleanCardNumber(value ?? '');
                  if (v.isEmpty) return l10n.translate('field_required');
                  if (!RegExp(r'^\d{16}$').hasMatch(v)) {
                    return l10n.cardNumberLengthError;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: _fieldGap),

              // kart sahibi adı
              _buildLabel(l10n.cardHolder),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardHolderController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: l10n.nameSurnameUp,
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.translate('field_required');
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: _fieldGap),

              _buildLabel(l10n.description),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: l10n.accountNameHint,
                  prefixIcon: const Icon(Icons.description_outlined),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.translate('field_required');
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: _fieldGap),

              // bakiye
              _buildLabel(l10n.balance),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[^0-9.]')),
                  _DotDecimalTextInputFormatter(decimalRange: 2),
                ],
                decoration: InputDecoration(
                  hintText: l10n.balanceHint,
                  prefix: isPrefix
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Text(
                            symbol,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  suffix: isPrefix
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(left: 8, right: 12),
                          child: Text(
                            symbol,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                ),
              ),
              const SizedBox(height: _fieldGap),

              // önizleme kartı
              if (_selectedBank != null) ...[
                Text(
                  l10n.preview,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _buildPreviewCard(),
                const SizedBox(height: 24),
              ],

              // gönder butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.createAccount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final l10n = context.l10n;

    final maskedCard = _cardNumberController.text.isEmpty
        ? '**** **** **** ****'
        : _cardNumberController.text;

    final holder = _cardHolderController.text.trim().isEmpty
        ? l10n.nameSurnameUp
        : _cardHolderController.text.trim();

    final desc = _descriptionController.text.trim().isEmpty
        ? '—'
        : _descriptionController.text.trim();

    return Container(
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
          Text(
            _selectedBank ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            maskedCard,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            holder,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
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

// kart numarası formatı : 4'lü gruplama
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;

    final formatted = _group4(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _group4(String digits) {
    final b = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      b.write(digits[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != digits.length) b.write(' ');
    }
    return b.toString();
  }
}
