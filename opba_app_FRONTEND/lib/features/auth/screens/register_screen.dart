import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/opba_logo.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  String? _selectedSecurityQuestion;
  bool _isLoading = false;

  final List<String> _securityQuestions = [
    'İlk evcil hayvanınızın adı nedir?',
    'Annenizin kızlık soyadı nedir?',
    'İlk okulunuzun adı nedir?',
    'En sevdiğiniz kitabın adı nedir?',
    'Doğduğunuz şehir neresidir?',
    'İlk arabanızın markası nedir?',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSecurityQuestion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir güvenlik sorusu seçin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate registration process
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });
    }
  }

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.gradientBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const OpbaLogoFull(height: 70),
                    const SizedBox(height: 20),

                    // Register Card
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
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
                          // Title
                          Text(
                            'Kayıt Ol',
                            style: AppTextStyles.title.copyWith(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Username field
                          CustomTextField(
                            label: 'Kullanıcı Adı',
                            hintText: 'Kullanıcı Adınızı Girin',
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kullanıcı adı gerekli';
                              }
                              if (value.length < 3) {
                                return 'Kullanıcı adı en az 3 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email field
                          CustomTextField(
                            label: 'E-posta',
                            hintText: 'E-Posta Adresinizi Girin',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'E-posta adresi gerekli';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Geçerli bir e-posta adresi girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Phone field
                          CustomTextField(
                            label: 'Telefon Numarası',
                            hintText: 'Telefon Numaranızı Girin',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Telefon numarası gerekli';
                              }
                              if (value.length < 10) {
                                return 'Geçerli bir telefon numarası girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password field
                          CustomTextField(
                            label: 'Şifre',
                            hintText: 'Şifrenizi Girin',
                            controller: _passwordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Confirm Password field
                          CustomTextField(
                            label: 'Şifre Tekrar',
                            hintText: 'Şifrenizi Tekrar Girin',
                            controller: _confirmPasswordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre tekrarı gerekli';
                              }
                              if (value != _passwordController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Security Question Dropdown
                          CustomDropdownField(
                            label: 'Güvenlik Sorusu',
                            hintText: 'Güvenlik Sorusunu Seçin',
                            items: _securityQuestions,
                            value: _selectedSecurityQuestion,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textHint,
                              size: AppDimensions.iconSizeSmall,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedSecurityQuestion = value;
                              });
                            },
                          ),
                          const SizedBox(height: 14),

                          // Security Answer field
                          CustomTextField(
                            label: 'Güvenlik Sorusunun Cevabı',
                            hintText: 'Güvenlik Sorusunun Cevabı',
                            controller: _securityAnswerController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Güvenlik sorusunun cevabı gerekli';
                              }
                              if (value.length < 2) {
                                return 'Cevap en az 2 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register button
                          CustomButton(
                            text: 'Kayıt Ol',
                            onPressed: _handleRegister,
                            isLoading: _isLoading,
                            width: 140,
                          ),
                          const SizedBox(height: 16),

                          // Login link
                          TextLinkButton(
                            text: 'Hesabınız Var Mı?',
                            linkText: 'Giriş Yapın',
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
