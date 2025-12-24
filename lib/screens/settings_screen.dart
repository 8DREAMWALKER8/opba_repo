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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
            // Profile Card
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
                          authProvider.user?.name ?? 'Kullanıcı',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.email ?? 'email@example.com',
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

            // Account Section
            _buildSectionTitle(context, 'Hesap'),
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
                    onChanged: (value) {
                      // TODO: Implement notification toggle
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionTitle(context, 'Tercihler'),
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
                    activeColor: AppColors.primaryBlue,
                  ),
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: appProvider.language == 'tr' ? 'Türkçe' : 'English',
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

            // About Section
            _buildSectionTitle(context, 'Hakkında'),
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
                  title: 'Sürüm',
                  subtitle: '1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
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

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.user?.name);
    final phoneController = TextEditingController(text: authProvider.user?.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.updateProfile(
                name: nameController.text,
                phone: phoneController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaydet'),
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
              leading: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
              title: const Text('Şifre Değiştir'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement password change
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.primaryBlue),
              title: const Text('Güvenlik Sorusu'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement security question change
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Türkçe'),
              value: 'tr',
              groupValue: appProvider.language,
              onChanged: (value) {
                appProvider.setLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Para Birimi Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('₺ Türk Lirası (TRY)'),
              value: 'TRY',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('\$ ABD Doları (USD)'),
              value: 'USD',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('€ Euro (EUR)'),
              value: 'EUR',
              groupValue: appProvider.currency,
              onChanged: (value) {
                appProvider.setCurrency(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('£ İngiliz Sterlini (GBP)'),
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
        title: Row(
          children: [
            Icon(Icons.account_balance, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            const Text('OPBA'),
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
              'OPBA, kişisel finans yönetiminizi kolaylaştırmak için '
              'tasarlanmış açık kaynaklı bir mobil bankacılık uygulamasıdır.',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}