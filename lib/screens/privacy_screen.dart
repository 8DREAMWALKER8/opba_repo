import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          l10n.privacyPolicy,
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
            // başlık karto
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
                children: [
                  const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'OPBA Gizlilik Politikası',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Son güncelleme: Aralık 2024',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // gizlilik bölümleri
            _buildSection(
              context,
              icon: Icons.info_outline,
              title: '1. Giriş',
              content: 'OPBA (Open Personal Banking Application) olarak, '
                  'kullanıcılarımızın gizliliğine büyük önem veriyoruz. '
                  'Bu gizlilik politikası, kişisel verilerinizin nasıl toplandığını, '
                  'kullanıldığını ve korunduğunu açıklamaktadır.',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.data_usage,
              title: '2. Toplanan Veriler',
              content: 'Uygulamamız aşağıdaki verileri toplamaktadır:\n\n'
                  '• Kimlik bilgileri (ad, e-posta, telefon)\n'
                  '• Hesap bilgileri (banka hesapları, kart numaraları)\n'
                  '• İşlem geçmişi ve harcama verileri\n'
                  '• Cihaz bilgileri ve uygulama kullanım verileri\n'
                  '• Konum bilgileri (izin verildiğinde)',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.settings_applications,
              title: '3. Verilerin Kullanımı',
              content:
                  'Toplanan veriler aşağıdaki amaçlarla kullanılmaktadır:\n\n'
                  '• Hesap yönetimi ve işlem takibi\n'
                  '• Bütçe analizi ve harcama raporları\n'
                  '• Kişiselleştirilmiş öneriler sunma\n'
                  '• Uygulama güvenliğinin sağlanması\n'
                  '• Müşteri desteği hizmetleri',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.lock_outline,
              title: '4. Veri Güvenliği',
              content:
                  'Verilerinizi korumak için aşağıdaki önlemleri alıyoruz:\n\n'
                  '• End-to-end şifreleme\n'
                  '• İki faktörlü kimlik doğrulama\n'
                  '• Güvenlik sorusu ile ek koruma\n'
                  '• SSL/TLS protokolleri\n'
                  '• Düzenli güvenlik denetimleri',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.share,
              title: '5. Veri Paylaşımı',
              content: 'Kişisel verileriniz, aşağıdaki durumlar dışında '
                  'üçüncü taraflarla paylaşılmaz:\n\n'
                  '• Yasal zorunluluklar\n'
                  '• Kullanıcı onayı ile\n'
                  '• Hizmet sağlayıcılarla (güvenlik standartlarına uygun)',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.person_outline,
              title: '6. Kullanıcı Hakları',
              content: 'KVKK kapsamında aşağıdaki haklara sahipsiniz:\n\n'
                  '• Verilerinize erişim hakkı\n'
                  '• Verilerin düzeltilmesini talep etme\n'
                  '• Verilerin silinmesini talep etme\n'
                  '• Veri işlemeye itiraz etme\n'
                  '• Veri taşınabilirliği',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.cookie,
              title: '7. Çerezler',
              content: 'Uygulamamız, kullanıcı deneyimini iyileştirmek için '
                  'çerezler ve benzer teknolojiler kullanmaktadır. '
                  'Çerez tercihlerinizi ayarlardan yönetebilirsiniz.',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.update,
              title: '8. Politika Güncellemeleri',
              content: 'Bu gizlilik politikası zaman zaman güncellenebilir. '
                  'Önemli değişiklikler olması durumunda kullanıcılarımızı '
                  'bilgilendireceğiz.',
              isDark: isDark,
            ),

            _buildSection(
              context,
              icon: Icons.mail_outline,
              title: '9. İletişim',
              content: 'Gizlilik politikamız hakkında sorularınız için:\n\n'
                  '📧 privacy@opba.com\n'
                  '📞 0850 XXX XX XX\n'
                  '🌐 www.opba.com/privacy',
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // kabul et butonu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bu gizlilik politikasını okudum ve kabul ediyorum.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Anladım.',
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
