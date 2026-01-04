import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

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
          l10n.settings,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user!.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user!.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      _showEditProfileDialog(context, authProvider);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, l10n.accountSection),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              isDark: isDark,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.person_outline,
                  title: l10n.editProfile,
                  onTap: () {
                    _showEditProfileDialog(context, authProvider);
                  },
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.lock_outline,
                  title: l10n.security,
                  onTap: () {
                    _showSecurityDialog(context);
                  },
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, l10n.preferencesSection),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              isDark: isDark,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: l10n.darkMode,
                  trailing: Switch(
                    value: appProvider.isDarkMode,
                    onChanged: (value) {
                      appProvider.setDarkMode(value);
                    },
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: appProvider.language == 'tr'
                      ? l10n.languageTurkish
                      : l10n.languageEnglish,
                  onTap: () {
                    _showLanguageDialog(context, appProvider);
                  },
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.attach_money,
                  title: l10n.currency,
                  subtitle: appProvider.currency,
                  onTap: () {
                    _showCurrencyDialog(context, appProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, l10n.aboutSection),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              isDark: isDark,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacy,
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.info_outline,
                  title: l10n.aboutUs,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.description_outlined,
                  title: l10n.version,
                  subtitle: '1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, authProvider);
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    // ✅ Kurallar ilk açılışta görünmesin
    bool showPasswordRules = false;
    List<String> passwordRuleErrors = [];

    // ✅ Register ekranındaki kuralları buraya birebir taşı
    List<String> validatePassword(String password) {
      final errors = <String>[];
      final p = password.trim();

      // ÖRNEK KURAL SETİ (register ile aynı yap)
      if (p.length < 8) errors.add('En az 8 karakter olmalı');
      if (!RegExp(r'[A-Z]').hasMatch(p))
        errors.add('En az 1 büyük harf içermeli');
      if (!RegExp(r'[a-z]').hasMatch(p))
        errors.add('En az 1 küçük harf içermeli');
      if (!RegExp(r'\d').hasMatch(p)) errors.add('En az 1 rakam içermeli');
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(p))
        errors.add('En az 1 özel karakter içermeli');

      return errors;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.lock_reset, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Text(
                'Şifre Değiştir',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),

              // Mevcut Şifre
              TextField(
                controller: currentPasswordController,
                obscureText: obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : const Color(0xFFF1F5F9),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => obscureCurrent = !obscureCurrent),
                    icon: Icon(
                      obscureCurrent ? Icons.visibility_off : Icons.visibility,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Yeni Şifre
              TextField(
                controller: newPasswordController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : const Color(0xFFF1F5F9),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscureNew = !obscureNew),
                    icon: Icon(
                      obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Yeni Şifre Tekrar
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : const Color(0xFFF1F5F9),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
                    icon: Icon(
                      obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),

              // ✅ Kurallar sadece hata sonrası gösterilsin
              if (showPasswordRules && passwordRuleErrors.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(isDark ? 0.35 : 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Şifre kuralları:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...passwordRuleErrors.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.close,
                                  size: 16, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final current = currentPasswordController.text.trim();
                final next = newPasswordController.text.trim();
                final confirm = confirmPasswordController.text.trim();

                // reset: her denemede eski hataları temizle
                setState(() {
                  showPasswordRules = false;
                  passwordRuleErrors = [];
                });

                if (next != confirm) {
                  setState(() {
                    showPasswordRules = true;
                    passwordRuleErrors = ['Yeni şifreler eşleşmiyor.'];
                  });
                  return;
                }

                if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // ✅ Kurallar: sadece başarısızsa göster
                final errors = validatePassword(next);
                if (errors.isNotEmpty) {
                  setState(() {
                    showPasswordRules = true;
                    passwordRuleErrors = errors;
                  });
                  return;
                }

                if (next != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yeni şifreler eşleşmiyor.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Burada backend çağrısı:
                final authProvider = context.read<AuthProvider>();
                final ok = await authProvider.updateProfile(
                  currentPassword: current,
                  password: next,
                );
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(authProvider.error ?? 'Şifre güncellenemedi.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre başarıyla güncellendi.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeSecurityQuestionDialog(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authProvider = context.read<AuthProvider>();

    // Eğer sorular daha önce çekilmediyse burada da garanti altına al
    // (authProvider.initSecurityQuestions varsa)
    // Future.microtask(() => authProvider.initSecurityQuestions(lang: 'tr'));

    final currentAnswerController = TextEditingController();
    final newAnswerController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;

    String? selectedNewQuestionId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final questions = context.watch<AuthProvider>().securityQuestions;

          // Mevcut soru metnini bul
          final currentQuestionId = authProvider.user?.securityQuestionId;
          debugPrint('Current question ID: $currentQuestionId');
          final currentQuestionText = (currentQuestionId == null)
              ? null
              : questions
                  .firstWhere(
                    (q) => q['id'] == currentQuestionId,
                    orElse: () => {},
                  )['text']
                  ?.toString();

          return AlertDialog(
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.security, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Text(
                  'Güvenlik Sorusu',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // Mevcut soru (read-only görünüm)
                  Text(
                    'Mevcut Güvenlik Sorusu',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      currentQuestionText ?? '—',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mevcut cevap
                  TextField(
                    controller: currentAnswerController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Mevcut Cevap',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : const Color(0xFFF1F5F9),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscureCurrent = !obscureCurrent),
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Yeni soru seçimi
                  Text(
                    'Yeni Güvenlik Sorusu',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedNewQuestionId,
                    decoration: InputDecoration(
                      hintText: l10n.securityQuestionSelect,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : const Color(0xFFF1F5F9),
                    ),
                    items: questions.map((q) {
                      final id = q['id']?.toString() ?? '';
                      final text = q['text']?.toString() ?? '';
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(
                          text,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedNewQuestionId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  // Yeni cevap
                  TextField(
                    controller: newAnswerController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Yeni Cevap',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : const Color(0xFFF1F5F9),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscureNew = !obscureNew),
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final currentAnswer = currentAnswerController.text.trim();
                  final newAnswer = newAnswerController.text.trim();
                  final newQid = selectedNewQuestionId;

                  // ✅ Zorunluluk kontrolleri
                  if (currentQuestionId == null || currentQuestionId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mevcut güvenlik sorusu bulunamadı.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (currentAnswer.isEmpty ||
                      newQid == null ||
                      newQid.isEmpty ||
                      newAnswer.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen tüm alanları doldurun.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // İstersen aynı soruyu seçmeyi engelle:
                  if (newQid == currentQuestionId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Yeni soru, mevcut sorudan farklı olmalıdır.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // ✅ Backend çağrısı (AuthProvider'da method yazacağız)
                  final ok = await authProvider.updateProfile(
                    securityAnswer: currentAnswer,
                    securityQuestionId: newQid,
                    newAnswer: newAnswer,
                  );

                  if (!ok && authProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.error!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Güvenlik sorusu başarıyla güncellendi.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final l10n = context.l10n;

    final fullNameController =
        TextEditingController(text: authProvider.user?.username);
    final emailController =
        TextEditingController(text: authProvider.user?.email);
    final phoneController =
        TextEditingController(text: authProvider.user?.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentUser = authProvider.user;
              final newFullname = fullNameController.text.trim();
              final newEmail = emailController.text.trim();
              final newPhone = phoneController.text.trim();

              final success = await authProvider.updateProfile(
                fullName:
                    newFullname.isEmpty ? currentUser?.username : newFullname,
                email: newEmail.isEmpty ? currentUser?.email : newEmail,
                phone: newPhone.isEmpty ? currentUser?.phone : newPhone,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil başarıyla güncellendi.'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              } else if (authProvider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.error!),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güvenlik Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
              title: const Text('Şifre Değiştir'),
              onTap: () {
                Navigator.pop(context); // security dialog kapanır
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.primaryBlue),
              title: const Text('Güvenlik Sorusu'),
              onTap: () {
                Navigator.pop(context);
                _showChangeSecurityQuestionDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider appProvider) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.languageSelectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.languageTurkish),
              value: 'tr',
              groupValue: appProvider.language,
              onChanged: (value) {
                appProvider.setLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageEnglish),
              value: 'en',
              groupValue: appProvider.language,
              onChanged: (value) {
                appProvider.setLanguage(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, AppProvider appProvider) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.currencySelectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.currencyTryLabel),
              value: 'TRY',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.currencyUsdLabel),
              value: 'USD',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.currencyEurLabel),
              value: 'EUR',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.currencyGbpLabel),
              value: 'GBP',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('OPBA'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Open Personal Banking Application',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'OPBA, kişisel finans yönetiminizi kolaylaştırmak için tasarlanmış açık kaynaklı bir mobil bankacılık uygulamasıdır.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text('Sürüm: 1.0.0'),
            Text('© 2024 OPBA'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
