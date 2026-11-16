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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Dinaikkan tiap kali login gagal supaya form bergetar.
  int _shakeTick = 0;

  void _onFieldFocusChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    if (_isLoading) return;
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
      // AuthGate otomatis mendeteksi perubahan status login dan pindah layar.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _pesanErrorRamah(e.code);
          _shakeTick++;
        });
      }
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
    _emailFocus.removeListener(_onFieldFocusChanged);
    _passwordFocus.removeListener(_onFieldFocusChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _loginCard(String? error) {
    return Shake(
      trigger: _shakeTick,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: appCardDecoration(
          radius: 28,
          shadow: AppShadows.soft,
          border: AppColors.line.withValues(alpha: 0.85),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FadeSlideIn(
                delay: Duration(milliseconds: 300),
                child: LoginGreeting(),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: const Duration(milliseconds: 380),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
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
                delay: const Duration(milliseconds: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Kata sandi'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      style: AppText.body.copyWith(fontSize: 15),
                      decoration: passwordInputDecoration(
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      )
                    else ...[
                      const LoginHero(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: _buildLoginForm(),
                          ),
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
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: const Duration(milliseconds: 540),
                child: AppButton(
                  label: 'Masuk ke sistem',
                  icon: Icons.arrow_forward_rounded,
                  height: 56,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _login,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 7),
                  Text('Khusus karyawan terdaftar', style: AppText.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final content = wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        flex: 11,
                        child: LoginHero(expanded: true),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        flex: 9,
                        child: Center(child: _loginCard(_errorMessage)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const LoginHero(),
                    const SizedBox(height: 16),
                    _loginCard(_errorMessage),
                  ],
                );

          return AnimatedPadding(
            duration: AppMotion.base,
            curve: AppMotion.out,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(wide ? 28 : 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: content,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
