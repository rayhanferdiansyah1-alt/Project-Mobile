import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/components/auth/auth_input_decoration.dart';
import '../ui/components/auth/gradient_login_button.dart';
import '../ui/components/auth/login_card.dart';
import '../ui/components/auth/login_error_banner.dart';
import '../ui/components/auth/login_hero.dart';
import '../ui/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Tidak perlu navigasi manual ke dashboard di sini --
      // AuthGate (lihat main.dart) akan otomatis mendeteksi
      // perubahan status login dan pindah layar sendiri.
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _pesanErrorRamah(e.code);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _pesanErrorRamah(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Gagal login: $code';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHero(),
                LoginCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LoginGreeting(),
                        const SizedBox(height: 26),

                        const CapsLabel('EMAIL'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 15),
                          decoration: emailInputDecoration(context),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        const CapsLabel('KATA SANDI'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 15),
                          decoration: passwordInputDecoration(
                            context,
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          LoginErrorBanner(_errorMessage!),
                        ],

                        const SizedBox(height: 26),
                        GradientLoginButton(
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _login,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
