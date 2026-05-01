import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedClassLevel = 'HSC';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().length < 2) return;
    if (_phoneController.text.trim().length < 11) return;
    if (_passwordController.text.length < 4) return;

    final auth = context.read<AuthService>();
    final success = await auth.register(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      classLevel: _selectedClassLevel,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('রেজিস্ট্রেশন', style: GoogleFonts.hindSiliguri()),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'নতুন অ্যাকাউন্ট তৈরি করুন',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'আপনার তথ্য দিয়ে শুরু করুন',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'পুরো নাম',
                        hintText: 'আপনার নাম লিখুন',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'ফোন নম্বর',
                        hintText: '01XXXXXXXXX',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        hintText: 'কমপক্ষে ৪ অক্ষর',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Class level dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedClassLevel,
                      decoration: InputDecoration(
                        labelText: 'ক্লাস লেভেল',
                        prefixIcon: const Icon(Icons.school_outlined, size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'SSC', child: Text('SSC (ক্লাস ৯-১০)')),
                        DropdownMenuItem(value: 'HSC', child: Text('HSC (ক্লাস ১১-১২)')),
                        DropdownMenuItem(value: 'Admission', child: Text('Admission (ভর্তি)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedClassLevel = v);
                      },
                    ),
                    const SizedBox(height: 28),

                    // Register button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleRegister,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'অ্যাকাউন্ট তৈরি করুন',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
