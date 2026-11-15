import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Dinaikkan tiap kali login gagal supaya form bergetar.
  int _shakeTick = 0;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _shakeTick++);
      return;
    }

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
        _shakeTick++;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _errorMessage;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginHero(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                32 + MediaQuery.of(context).padding.bottom,
              ),
              child: Shake(
                trigger: _shakeTick,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 360),
                        child: LoginGreeting(),
                      ),
                      const SizedBox(height: 24),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FieldLabel('Email'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: AppText.body.copyWith(fontSize: 15),
                              decoration: emailInputDecoration(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FieldLabel('Kata sandi'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: AppText.body.copyWith(fontSize: 15),
                              decoration: passwordInputDecoration(
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
                          ],
                        ),
                      ),
                      AnimatedSize(
                        duration: AppMotion.base,
                        curve: AppMotion.out,
                        alignment: Alignment.topCenter,
                        child: error == null
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: LoginErrorBanner(error, key: ValueKey(error)),
                              ),
                      ),
                      const SizedBox(height: 26),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 600),
                        child: AppButton(
                          label: 'Masuk',
                          icon: Icons.arrow_forward_rounded,
                          height: 56,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _login,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Khusus karyawan terdaftar',
                          style: AppText.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
