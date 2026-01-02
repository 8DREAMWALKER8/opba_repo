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
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'logout': 'Çıkış Yap',
      'name': 'Ad',
      'surname': 'Soyad',
      'namePlaceholder': 'Adınızı girin',
      'surnamePlaceholder': 'Soyadınızı girin',
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
      'full_name': 'Ad Soyad',
      'account_section': 'Hesap',
      'preferences_section': 'Tercihler',
      'about_section': 'Hakkında',
      'version': 'Sürüm',
      'security_question': 'Güvenlik Sorusu',
      'security_question_select': 'Güvenlik sorusunu seçin',
      'security_answer': 'Güvenlik Sorusunun Cevabı',
      'security_answer_hint': 'Güvenlik Sorusunun Cevabı',
      'sq_mother_maiden': 'Annenizin kızlık soyadı nedir?',
      'sq_first_pet': 'İlk evcil hayvanınızın adı nedir?',
      'sq_birth_city': 'Hangi şehirde doğdunuz?',
      'sq_first_school': 'İlk okulunuzun adı nedir?',
      'sq_favorite_movie': 'En sevdiğiniz film hangisidir?',
      'home': 'Ana Sayfa',
      'accounts': 'Hesaplar',
      'expenses': 'Harcama',
      'credit': 'Kredi',
      'settings': 'Ayarlar',
      'total_balance': 'Toplam Bakiye',
      'recent_transactions': 'Son İşlemler',
      'add_new_account': 'YENİ HESAP EKLE +',
      'view_all': 'Tümünü Gör',
      'my_accounts': 'Hesaplarım',
      'add_account': 'Hesap Ekle',
      'card_number': 'Kart Numarası',
      'card_number_hint': '1234 5678 1234 5678',
      'iban': 'IBAN',
      'iban_hint': 'Örn: TR00 0000 0000 0000 0000 00',
      'bank_select': 'Banka Seç',
      'balance': 'Bakiye',
      'create_account': 'Hesap Oluştur',
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
      'expenses_screen': 'Harcama Ekranı',
      'category_market': 'Market',
      'category_bills': 'Faturalar',
      'category_entertainment': 'Eğlence',
      'category_transport': 'Ulaşım',
      'category_food': 'Yemek',
      'category_health': 'Sağlık',
      'category_shopping': 'Alışveriş',
      'category_other': 'Diğer',
      'budget_management': 'Bütçe Yönetimi',
      'select_category': 'Kategori Seç',
      'set_limit': 'Üst Limit Belirle',
      'limit_hint': 'Örn: 5000 TL',
      'approve': 'Onayla',
      'credit_comparison': 'Kredi Karşılaştırma',
      'interest_rate': 'Faiz Oranı',
      'best_rate': 'En Uygun',
      'monthly_payment': 'Aylık Taksit',
      'loan_term': 'Vade',
      'months': 'ay',
      'personal_loan_rates_title': 'İhtiyaç Kredisi Faiz Oranları',
      'personal_loan_rates_desc':
          'Aşağıda bankaların güncel ihtiyaç kredisi faiz oranlarını karşılaştırabilirsiniz.',
      'bank_interest_rates': 'Banka Faiz Oranları',
      'personal_loan': 'İhtiyaç Kredisi',
      'monthly_interest': 'aylık faiz',
      'loan_calculator': 'Kredi Hesaplama',
      'best': 'EN İYİ',
      'loan_amount': 'Kredi Tutarı',
      'loan_term_months': 'Vade (Ay)',
      'installment_monthly': 'Aylık Taksit:',
      'total_payment': 'Toplam Ödeme:',
      'language_select_title': 'Dil Seçin',
      'language_turkish': 'Türkçe',
      'language_english': 'English',
      'edit_profile': 'Profili Düzenle',
      'security': 'Güvenlik',
      'notifications': 'Bildirimler',
      'privacy': 'Gizlilik',
      'about_us': 'Hakkımızda',
      'language': 'Dil',
      'currency': 'Para Birimi',
      'dark_mode': 'Koyu Mod',
      'currency_select_title': 'Para Birimi Seçin',
      'currency_try_label': '₺ Türk Lirası (TRY)',
      'currency_usd_label': '\$ ABD Doları (USD)',
      'currency_eur_label': '€ Euro (EUR)',
      'currency_gbp_label': '£ İngiliz Sterlini (GBP)',
      'privacy_policy': 'Gizlilik Politikası',
      'field_required': 'Bu alan zorunludur.',
      'invalid_email': 'Geçersiz e-posta adresi',
      'password_too_short': 'Şifre en az 6 karakter olmalıdır.',
      'passwords_not_match': 'Şifreler eşleşmiyor.',
      'invalid_card_number': 'Geçersiz kart numarası',
      'invalid_iban': 'Geçersiz IBAN',
      'logout_title': 'Çıkış Yap',
      'logout_confirm': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      'back_to_login': 'Geri Dön',
      'total_expenses': 'Toplam Harcama',
      'this_month': 'Bu ay',
      'categories_title': 'Kategoriler',
      'no_expense_data': 'Henüz harcama verisi yok',
    },
    'en': {
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
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'name': 'Name',
      'surname': 'Surname',
      'namePlaceholder': 'Enter your name',
      'surnamePlaceholder': 'Enter your surname',
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
      'full_name': 'Full Name',
      'account_section': 'Account',
      'preferences_section': 'Preferences',
      'about_section': 'About',
      'version': 'Version',
      'security_question': 'Security Question',
      'security_question_select': 'Select security question',
      'security_answer': 'Security Answer',
      'security_answer_hint': 'Enter your answer',
      'sq_mother_maiden': "What is your mother's maiden name?",
      'sq_first_pet': 'What was the name of your first pet?',
      'sq_birth_city': 'In which city were you born?',
      'sq_first_school': 'What was the name of your first school?',
      'sq_favorite_movie': 'What is your favorite movie?',
      'home': 'Home',
      'accounts': 'Accounts',
      'expenses': 'Expenses',
      'credit': 'Credit',
      'settings': 'Settings',
      'total_balance': 'Total Balance',
      'recent_transactions': 'Recent Transactions',
      'add_new_account': 'ADD NEW ACCOUNT +',
      'view_all': 'View All',
      'my_accounts': 'My Accounts',
      'add_account': 'Add Account',
      'card_number': 'Card Number',
      'card_number_hint': '1234 5678 1234 5678',
      'iban': 'IBAN',
      'iban_hint': 'Ex: TR00 0000 0000 0000 0000 00',
      'bank_select': 'Select Bank',
      'balance': 'Balance',
      'create_account': 'Create Account',
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
      'expenses_screen': 'Expenses',
      'category_market': 'Market',
      'category_bills': 'Bills',
      'category_entertainment': 'Entertainment',
      'category_transport': 'Transport',
      'category_food': 'Food',
      'category_health': 'Health',
      'category_shopping': 'Shopping',
      'category_other': 'Other',
      'budget_management': 'Budget Management',
      'select_category': 'Select Category',
      'set_limit': 'Set Limit',
      'limit_hint': 'Ex: 5000 TL',
      'approve': 'Approve',
      'credit_comparison': 'Credit Comparison',
      'interest_rate': 'Interest Rate',
      'best_rate': 'Best Rate',
      'monthly_payment': 'Monthly Payment',
      'loan_term': 'Term',
      'months': 'months',
      'personal_loan_rates_title': 'Personal Loan Interest Rates',
      'personal_loan_rates_desc':
          'You can compare current personal loan interest rates from banks below.',
      'bank_interest_rates': 'Bank Interest Rates',
      'personal_loan': 'Personal Loan',
      'monthly_interest': 'monthly interest',
      'loan_calculator': 'Loan Calculator',
      'best': 'BEST',
      'loan_amount': 'Loan Amount',
      'loan_term_months': 'Term (Months)',
      'installment_monthly': 'Monthly Installment:',
      'total_payment': 'Total Payment:',
      'language_select_title': 'Select Language',
      'language_turkish': 'Turkish',
      'language_english': 'English',
      'edit_profile': 'Edit Profile',
      'security': 'Security',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'about_us': 'About Us',
      'language': 'Language',
      'currency': 'Currency',
      'dark_mode': 'Dark Mode',
      'currency_select_title': 'Select Currency',
      'currency_try_label': '₺ Turkish Lira (TRY)',
      'currency_usd_label': '\$ US Dollar (USD)',
      'currency_eur_label': '€ Euro (EUR)',
      'currency_gbp_label': '£ British Pound (GBP)',
      'privacy_policy': 'Privacy Policy',
      'field_required': 'This field is required',
      'invalid_email': 'Invalid email address',
      'password_too_short': 'Password must be at least 6 characters',
      'passwords_not_match': 'Passwords do not match',
      'invalid_card_number': 'Invalid card number',
      'invalid_iban': 'Invalid IBAN',
      'logout_title': 'Logout',
      'logout_confirm': 'Are you sure you want to log out?',
      'back_to_login': 'Go Back',
      'total_expenses': 'Total Expenses',
      'this_month': 'This month',
      'categories_title': 'Categories',
      'no_expense_data': 'No expense data yet',
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
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get name => translate('name');
  String get surname => translate('surname');
  String get namePlaceholder => translate('namePlaceholder');
  String get surnamePlaceholer => translate('surnamePlaceholder');
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
  String get fullName => translate('full_name');
  String get accountSection => translate('account_section');
  String get preferencesSection => translate('preferences_section');
  String get aboutSection => translate('about_section');
  String get version => translate('version');
  String get securityQuestion => translate('security_question');
  String get securityQuestionSelect => translate('security_question_select');
  String get securityAnswer => translate('security_answer');
  String get securityAnswerHint => translate('security_answer_hint');
  String get home => translate('home');
  String get accounts => translate('accounts');
  String get expenses => translate('expenses');
  String get credit => translate('credit');
  String get settings => translate('settings');
  String get totalBalance => translate('total_balance');
  String get recentTransactions => translate('recent_transactions');
  String get addNewAccount => translate('add_new_account');
  String get viewAll => translate('view_all');
  String get myAccounts => translate('my_accounts');
  String get addAccount => translate('add_account');
  String get cardNumber => translate('card_number');
  String get cardNumberHint => translate('card_number_hint');
  String get iban => translate('iban');
  String get ibanHint => translate('iban_hint');
  String get bankSelect => translate('bank_select');
  String get balance => translate('balance');
  String get createAccount => translate('create_account');
  String get budgetManagement => translate('budget_management');
  String get selectCategory => translate('select_category');
  String get setLimit => translate('set_limit');
  String get limitHint => translate('limit_hint');
  String get approve => translate('approve');
  String get creditComparison => translate('credit_comparison');
  String get interestRate => translate('interest_rate');
  String get bestRate => translate('best_rate');
  String get monthlyPayment => translate('monthly_payment');
  String get loanTerm => translate('loan_term');
  String get months => translate('months');
  String get personalLoanRatesTitle => translate('personal_loan_rates_title');
  String get personalLoanRatesDesc => translate('personal_loan_rates_desc');
  String get bankInterestRates => translate('bank_interest_rates');
  String get personalLoan => translate('personal_loan');
  String get monthlyInterest => translate('monthly_interest');
  String get loanCalculator => translate('loan_calculator');
  String get best => translate('best');
  String get loanAmount => translate('loan_amount');
  String get loanTermMonths => translate('loan_term_months');
  String get installmentMonthly => translate('installment_monthly');
  String get totalPayment => translate('total_payment');
  String get languageSelectTitle => translate('language_select_title');
  String get languageTurkish => translate('language_turkish');
  String get languageEnglish => translate('language_english');
  String get editProfile => translate('edit_profile');
  String get security => translate('security');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get aboutUs => translate('about_us');
  String get language => translate('language');
  String get currency => translate('currency');
  String get darkMode => translate('dark_mode');
  String get currencySelectTitle => translate('currency_select_title');
  String get currencyTryLabel => translate('currency_try_label');
  String get currencyUsdLabel => translate('currency_usd_label');
  String get currencyEurLabel => translate('currency_eur_label');
  String get currencyGbpLabel => translate('currency_gbp_label');
  String get privacyPolicy => translate('privacy_policy');
  String get logoutTitle => translate('logout_title');
  String get logoutConfirm => translate('logout_confirm');
  String get backToLogin => translate('back_to_login');

  List<Map<String, String>> get securityQuestions => [
        {'id': 'q1', 'text': translate('sq_mother_maiden')},
        {'id': 'q2', 'text': translate('sq_first_pet')},
        {'id': 'q3', 'text': translate('sq_birth_city')},
        {'id': 'q4', 'text': translate('sq_first_school')},
        {'id': 'q5', 'text': translate('sq_favorite_movie')},
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

// kolay erişim için extension
extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
