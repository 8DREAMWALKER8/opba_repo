import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/opba_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  String? _selectedSecurityQuestion;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSecurityQuestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.securityQuestionSelect),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      username:
          "${_nameController.text.trim()} ${_surnameController.text.trim()}",
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _confirmPasswordController.text,
      securityQuestionId: _selectedSecurityQuestion!,
      securityAnswer: _securityAnswerController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('kayıt başarılı, lütfen giriş yapın.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const OpbaLogo(size: 0.8),
                  const SizedBox(height: 20),
                  // kayıt ol kartı
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.register,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        // ad
                        _buildLabeledField(l10n.name, isDark),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: l10n.namePlaceholder,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.translate('field_required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // soyad
                        _buildLabeledField(l10n.surname, isDark),
                        TextFormField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            hintText: l10n.surnamePlaceholer,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.translate('field_required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // e-posta
                        _buildLabeledField(l10n.email, isDark),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: l10n.emailHint,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.translate('field_required');
                            }
                            if (!value.contains('@')) {
                              return l10n.translate('invalid_email');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // telefon numarası
                        _buildLabeledField(l10n.phone, isDark),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: l10n.phoneHint,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.translate('field_required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // şifre
                        _buildLabeledField(l10n.password, isDark),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: l10n.passwordHint,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.translate('field_required');
                            }
                            if (value.length < 6) {
                              return l10n.translate('password_too_short');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // şifremi unuttum
                        _buildLabeledField(l10n.passwordConfirm, isDark),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: l10n.passwordConfirmHint,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return l10n.translate('passwords_not_match');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // güvenlik sorusu
                        _buildLabeledField(l10n.securityQuestion, isDark,
                            icon: Icons.search),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSecurityQuestion,
                          decoration: InputDecoration(
                            hintText: l10n.securityQuestionSelect,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                          ),
                          items: l10n.securityQuestions.map((question) {
                            return DropdownMenuItem(
                              value: question['id'],
                              child: Text(
                                question['text']!,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSecurityQuestion = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // güvenlik sorusu cevabı
                        _buildLabeledField(l10n.securityAnswer, isDark),
                        TextFormField(
                          controller: _securityAnswerController,
                          decoration: InputDecoration(
                            hintText: l10n.securityAnswerHint,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFF1F5F9),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.translate('field_required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // kayıt ol butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    l10n.register,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // giriş yap linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.haveAccount,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.loginNow,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, bool isDark, {IconData? icon}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
