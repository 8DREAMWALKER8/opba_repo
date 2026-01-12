import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class EditAccountScreen extends StatefulWidget {
  final Account account;

  const EditAccountScreen({
    super.key,
    required this.account,
  });

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardHolderController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _balanceController;
  AppLocalizations get l10n => context.l10n;

  String? _selectedBank;
  bool _isLoading = false;

  static const _gap = 20.0;

  @override
  void initState() {
    super.initState();

    _selectedBank = widget.account.bankName;

    _cardNumberController = TextEditingController(
      text: _group4((widget.account.cardNumber ?? '').trim()),
    );

    _cardHolderController = TextEditingController(
      text: (widget.account.cardHolderName ?? '').trim(),
    );

    _descriptionController = TextEditingController(
      text: (widget.account.description ?? '').trim(),
    );

    _balanceController = TextEditingController(
      text: widget.account.balance.toStringAsFixed(2),
    );
  }

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

    final accountProvider = context.read<AccountProvider>();

    final cardNumber = _cleanCardNumber(_cardNumberController.text);
    final balance =
        double.tryParse(_balanceController.text) ?? widget.account.balance;

    final updated = widget.account.copyWith(
      bankName: _selectedBank!,
      cardNumber: cardNumber,
      cardHolderName: _cardHolderController.text.trim(),
      description: _descriptionController.text.trim(),
      balance: balance,
    );

    final ok = await accountProvider.updateAccount(updated);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountUpdatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountUpdateFailed),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    // oturum kontrolü
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sessionNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Text(l10n.deleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final accountProvider = context.read<AccountProvider>();
    final ok = await accountProvider.deleteAccount(widget.account.id!);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountDeleted),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      final err = accountProvider.error ?? l10n.accountDeleteFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auth = context.watch<AuthProvider>();
    final userCurrency =
        (auth.user?.currency ?? widget.account.currency).toUpperCase();
    final symbol = _currencySymbol(userCurrency);
    final isPrefix =
        userCurrency == 'USD' || userCurrency == 'EUR' || userCurrency == 'GBP';

    final selected = (_selectedBank ?? '').trim();
    final bankNames =
        Bank.turkishBanks.map((b) => b.name.trim()).toSet().toList()..sort();
    final dropdownValue = bankNames.contains(selected) ? selected : null;

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
          l10n.editAccount,
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
              // banka
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
                  value: dropdownValue,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  hint: Text(l10n.bankSelect),
                  items: bankNames.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance,
                              color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBank = value),
                ),
              ),

              const SizedBox(height: _gap),

              // kart Numarası
              _buildLabel(l10n.cardNumber),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [_CardNumberFormatter()],
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

              const SizedBox(height: _gap),

              // kart Sahibi
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
                    return l10n.fieldRequired;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: _gap),

              // description
              _buildLabel(l10n.description),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: l10n.accountNameExample,
                  prefixIcon: const Icon(Icons.edit_note),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: _gap),

              // balance
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
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: isPrefix ? '$symbol ' : null,
                  suffixText: isPrefix ? null : ' $symbol',
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 18),

              _buildPreviewCard(isDark),

              const SizedBox(height: 24),

              // save
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
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // silme işlemi
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.deleteAccountTitle,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    final bank = (_selectedBank ?? '').trim();
    final masked = _cardNumberController.text.trim().isEmpty
        ? '**** **** **** ****'
        : _cardNumberController.text.trim();
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
            AppColors.primaryGradientEnd
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
            bank,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            masked,
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
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _currencySymbol(String code) {
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

  String _group4(String digitsRaw) {
    final digits = digitsRaw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final b = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      b.write(digits[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != digits.length) b.write(' ');
    }
    return b.toString();
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
    if (parts.length == 2 && parts[1].length > decimalRange) return oldValue;
    return newValue;
  }
}

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
