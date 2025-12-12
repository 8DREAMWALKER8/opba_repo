import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/opba_logo.dart';
import '../../../features/auth/screens/Accounts_Screen.dart';

class SecurityQuestionScreen extends StatefulWidget {
  const SecurityQuestionScreen({super.key});

  @override
  State<SecurityQuestionScreen> createState() => _SecurityQuestionScreenState();
}

class _SecurityQuestionScreenState extends State<SecurityQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  String? _selectedQuestion;
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
    _answerController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedQuestion == null) {
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

      // Simulate verification process
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });

        // Navigate to accounts screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountsScreen(),
          ),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
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
                    const OpbaLogoFull(height: 80),
                    const SizedBox(height: 40),

                    // Security Question Card
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
                          // Security Question Dropdown
                          CustomDropdownField(
                            label: 'Güvenlik Sorusu',
                            hintText: 'Güvenlik Sorusunu Seçin',
                            items: _securityQuestions,
                            value: _selectedQuestion,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textHint,
                              size: AppDimensions.iconSizeSmall,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedQuestion = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Answer field
                          CustomTextField(
                            label: 'Güvenlik Sorusunun Cevabı',
                            hintText: 'Güvenlik Sorusunun Cevabı',
                            controller: _answerController,
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
                          const SizedBox(height: 30),

                          // Submit button
                          CustomButton(
                            text: 'Giriş Yap',
                            onPressed: _handleSubmit,
                            isLoading: _isLoading,
                            width: 140,
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