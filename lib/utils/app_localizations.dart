import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      // General
      'app_name': 'OPBA',
      'welcome': 'Hoş Geldiniz',
      'continue_btn': 'İlerle',
      'cancel': 'İptal',
      'save': 'Kaydet',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'confirm': 'Onayla',
      'back': 'Geri',
      'next': 'İleri',
      'loading': 'Yükleniyor...',
      'error': 'Hata',
      'success': 'Başarılı',
      
      // Auth
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'logout': 'Çıkış Yap',
      'email': 'E-posta',
      'email_hint': 'E-Posta Adresinizi Girin',
      'password': 'Şifre',
      'password_hint': 'Şifrenizi Girin',
      'password_confirm': 'Şifre Tekrar',
      'password_confirm_hint': 'Şifrenizi Tekrar Girin',
      'username': 'Kullanıcı Adı',
      'username_hint': 'Kullanıcı Adınızı Girin',
      'phone': 'Telefon Numarası',
      'phone_hint': 'Telefon Numaranızı Girin',
      'forgot_password': 'Şifremi Unuttum',
      'no_account': 'Hesabınız Yok Mu?',
      'have_account': 'Hesabınız Var Mı?',
      'register_now': 'Hemen Kaydolun',
      'login_now': 'Giriş Yapın',
      
      // Security Question
      'security_question': 'Güvenlik Sorusu',
      'security_question_select': 'Güvenlik Sorusunu Seçin',
      'security_answer': 'Güvenlik Sorusunun Cevabı',
      'security_answer_hint': 'Güvenlik Sorusunun Cevabı',
      'sq_mother_maiden': 'Annenizin kızlık soyadı nedir?',
      'sq_first_pet': 'İlk evcil hayvanınızın adı nedir?',
      'sq_birth_city': 'Hangi şehirde doğdunuz?',
      'sq_first_school': 'İlk okulunuzun adı nedir?',
      'sq_favorite_movie': 'En sevdiğiniz film hangisidir?',
      
      // Navigation
      'home': 'Ana Sayfa',
      'accounts': 'Hesaplar',
      'expenses': 'Harcama',
      'credit': 'Kredi',
      'settings': 'Ayarlar',
      
      // Home Screen
      'total_balance': 'Toplam Bakiye',
      'recent_transactions': 'Son İşlemler',
      'add_new_account': 'YENİ HESAP EKLE +',
      'view_all': 'Tümünü Gör',
      
      // Accounts
      'my_accounts': 'Hesaplarım',
      'add_account': 'Hesap Ekle',
      'card_number': 'Kart Numarası',
      'card_number_hint': '1234 5678 1234 5678',
      'iban': 'IBAN',
      'iban_hint': 'Örn: TR00 0000 0000 0000 0000 00',
      'bank_select': 'Banka Seç',
      'balance': 'Bakiye',
      'create_account': 'Hesap Oluştur',
      
      // Banks
      'ziraat_bank': 'Ziraat Bankası',
      'is_bank': 'İş Bankası',
      'garanti_bank': 'Garanti BBVA',
      'yapi_kredi': 'Yapı Kredi',
      'akbank': 'Akbank',
      'halkbank': 'Halkbank',
      'vakifbank': 'VakıfBank',
      'qnb_finansbank': 'QNB Finansbank',
      'denizbank': 'DenizBank',
      'teb': 'TEB',
      'ing': 'ING',
      'hsbc': 'HSBC',
      'enpara': 'Enpara',
      
      // Expenses
      'expenses_screen': 'Harcama Ekranı',
      'category_market': 'Market',
      'category_bills': 'Faturalar',
      'category_entertainment': 'Eğlence',
      'category_transport': 'Ulaşım',
      'category_food': 'Yemek',
      'category_health': 'Sağlık',
      'category_shopping': 'Alışveriş',
      'category_other': 'Diğer',
      
      // Budget
      'budget_management': 'Bütçe Yönetimi',
      'select_category': 'Kategori Seç',
      'set_limit': 'Üst Limit Belirle',
      'limit_hint': 'Örn: 5000 TL',
      'approve': 'Onayla',
      
      // Credit
      'credit_comparison': 'Kredi Karşılaştırma',
      'interest_rate': 'Faiz Oranı',
      'best_rate': 'En Uygun',
      'monthly_payment': 'Aylık Taksit',
      'loan_term': 'Vade',
      'months': 'ay',
      
      // Settings
      'edit_profile': 'Profili Düzenle',
      'security': 'Güvenlik',
      'notifications': 'Bildirimler',
      'privacy': 'Gizlilik',
      'about_us': 'Hakkımızda',
      'language': 'Dil',
      'currency': 'Para Birimi',
      'dark_mode': 'Koyu Mod',
      
      // Privacy
      'privacy_policy': 'Gizlilik Politikası',
      
      // Validation
      'field_required': 'Bu alan zorunludur',
      'invalid_email': 'Geçersiz e-posta adresi',
      'password_too_short': 'Şifre en az 6 karakter olmalıdır',
      'passwords_not_match': 'Şifreler eşleşmiyor',
      'invalid_card_number': 'Geçersiz kart numarası',
      'invalid_iban': 'Geçersiz IBAN',
    },
    'en': {
      // General
      'app_name': 'OPBA',
      'welcome': 'Welcome',
      'continue_btn': 'Continue',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'confirm': 'Confirm',
      'back': 'Back',
      'next': 'Next',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Auth
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'E-mail',
      'email_hint': 'Enter your email',
      'password': 'Password',
      'password_hint': 'Enter your password',
      'password_confirm': 'Confirm Password',
      'password_confirm_hint': 'Confirm your password',
      'username': 'Username',
      'username_hint': 'Enter your username',
      'phone': 'Phone Number',
      'phone_hint': 'Enter your phone number',
      'forgot_password': 'Forgot Password',
      'no_account': "Don't have an account?",
      'have_account': 'Already have an account?',
      'register_now': 'Register Now',
      'login_now': 'Login',
      
      // Security Question
      'security_question': 'Security Question',
      'security_question_select': 'Select Security Question',
      'security_answer': 'Security Answer',
      'security_answer_hint': 'Enter your answer',
      'sq_mother_maiden': "What is your mother's maiden name?",
      'sq_first_pet': 'What was the name of your first pet?',
      'sq_birth_city': 'In which city were you born?',
      'sq_first_school': 'What was the name of your first school?',
      'sq_favorite_movie': 'What is your favorite movie?',
      
      // Navigation
      'home': 'Home',
      'accounts': 'Accounts',
      'expenses': 'Expenses',
      'credit': 'Credit',
      'settings': 'Settings',
      
      // Home Screen
      'total_balance': 'Total Balance',
      'recent_transactions': 'Recent Transactions',
      'add_new_account': 'ADD NEW ACCOUNT +',
      'view_all': 'View All',
      
      // Accounts
      'my_accounts': 'My Accounts',
      'add_account': 'Add Account',
      'card_number': 'Card Number',
      'card_number_hint': '1234 5678 1234 5678',
      'iban': 'IBAN',
      'iban_hint': 'Ex: TR00 0000 0000 0000 0000 00',
      'bank_select': 'Select Bank',
      'balance': 'Balance',
      'create_account': 'Create Account',
      
      // Banks
      'ziraat_bank': 'Ziraat Bank',
      'is_bank': 'İş Bank',
      'garanti_bank': 'Garanti BBVA',
      'yapi_kredi': 'Yapı Kredi',
      'akbank': 'Akbank',
      'halkbank': 'Halkbank',
      'vakifbank': 'VakıfBank',
      'qnb_finansbank': 'QNB Finansbank',
      'denizbank': 'DenizBank',
      'teb': 'TEB',
      'ing': 'ING',
      'hsbc': 'HSBC',
      'enpara': 'Enpara',
      
      // Expenses
      'expenses_screen': 'Expenses',
      'category_market': 'Market',
      'category_bills': 'Bills',
      'category_entertainment': 'Entertainment',
      'category_transport': 'Transport',
      'category_food': 'Food',
      'category_health': 'Health',
      'category_shopping': 'Shopping',
      'category_other': 'Other',
      
      // Budget
      'budget_management': 'Budget Management',
      'select_category': 'Select Category',
      'set_limit': 'Set Limit',
      'limit_hint': 'Ex: 5000 TL',
      'approve': 'Approve',
      
      // Credit
      'credit_comparison': 'Credit Comparison',
      'interest_rate': 'Interest Rate',
      'best_rate': 'Best Rate',
      'monthly_payment': 'Monthly Payment',
      'loan_term': 'Term',
      'months': 'months',
      
      // Settings
      'edit_profile': 'Edit Profile',
      'security': 'Security',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'about_us': 'About Us',
      'language': 'Language',
      'currency': 'Currency',
      'dark_mode': 'Dark Mode',
      
      // Privacy
      'privacy_policy': 'Privacy Policy',
      
      // Validation
      'field_required': 'This field is required',
      'invalid_email': 'Invalid email address',
      'password_too_short': 'Password must be at least 6 characters',
      'passwords_not_match': 'Passwords do not match',
      'invalid_card_number': 'Invalid card number',
      'invalid_iban': 'Invalid IBAN',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get continueBtn => translate('continue_btn');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get confirm => translate('confirm');
  String get back => translate('back');
  String get next => translate('next');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  
  // Auth
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get email => translate('email');
  String get emailHint => translate('email_hint');
  String get password => translate('password');
  String get passwordHint => translate('password_hint');
  String get passwordConfirm => translate('password_confirm');
  String get passwordConfirmHint => translate('password_confirm_hint');
  String get username => translate('username');
  String get usernameHint => translate('username_hint');
  String get phone => translate('phone');
  String get phoneHint => translate('phone_hint');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get haveAccount => translate('have_account');
  String get registerNow => translate('register_now');
  String get loginNow => translate('login_now');
  
  // Security
  String get securityQuestion => translate('security_question');
  String get securityQuestionSelect => translate('security_question_select');
  String get securityAnswer => translate('security_answer');
  String get securityAnswerHint => translate('security_answer_hint');
  
  // Navigation
  String get home => translate('home');
  String get accounts => translate('accounts');
  String get expenses => translate('expenses');
  String get credit => translate('credit');
  String get settings => translate('settings');
  
  // Home
  String get totalBalance => translate('total_balance');
  String get recentTransactions => translate('recent_transactions');
  String get addNewAccount => translate('add_new_account');
  String get viewAll => translate('view_all');
  
  // Accounts
  String get myAccounts => translate('my_accounts');
  String get addAccount => translate('add_account');
  String get cardNumber => translate('card_number');
  String get cardNumberHint => translate('card_number_hint');
  String get iban => translate('iban');
  String get ibanHint => translate('iban_hint');
  String get bankSelect => translate('bank_select');
  String get balance => translate('balance');
  String get createAccount => translate('create_account');
  
  // Budget
  String get budgetManagement => translate('budget_management');
  String get selectCategory => translate('select_category');
  String get setLimit => translate('set_limit');
  String get limitHint => translate('limit_hint');
  String get approve => translate('approve');
  
  // Credit
  String get creditComparison => translate('credit_comparison');
  String get interestRate => translate('interest_rate');
  String get bestRate => translate('best_rate');
  String get monthlyPayment => translate('monthly_payment');
  String get loanTerm => translate('loan_term');
  String get months => translate('months');
  
  // Settings
  String get editProfile => translate('edit_profile');
  String get security => translate('security');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get aboutUs => translate('about_us');
  String get language => translate('language');
  String get currency => translate('currency');
  String get darkMode => translate('dark_mode');
  
  String get privacyPolicy => translate('privacy_policy');
  
  // Get security questions list
  List<String> get securityQuestions => [
    translate('sq_mother_maiden'),
    translate('sq_first_pet'),
    translate('sq_birth_city'),
    translate('sq_first_school'),
    translate('sq_favorite_movie'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}