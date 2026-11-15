import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/ui.dart';

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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

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
    _emailFocus.addListener(_onFieldFocusChanged);
    _passwordFocus.addListener(_onFieldFocusChanged);
    _animCtrl.forward();
  }

  void _onFieldFocusChanged() {
    if (mounted) setState(() {});
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
      // AuthGate otomatis mendeteksi perubahan status login dan pindah layar.
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
    _emailFocus.removeListener(_onFieldFocusChanged);
    _passwordFocus.removeListener(_onFieldFocusChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (constraints.maxWidth >= 820)
                      SizedBox(
                        height: constraints.maxHeight,
                        child: Row(
                          children: [
                            Expanded(flex: 11, child: const LoginHero()),
                            Expanded(
                              flex: 9,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 460,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 44,
                                      vertical: 30,
                                    ),
                                    child: _buildLoginForm(),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() => LoginCard(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoginGreeting(),
          const SizedBox(height: 30),
          const CapsLabel('EMAIL'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: emailInputDecoration(focused: _emailFocus.hasFocus),
            onEditingComplete: _passwordFocus.requestFocus,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Email tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 21),
          const CapsLabel('KATA SANDI'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _isLoading ? null : _login(),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: passwordInputDecoration(
              obscure: _obscurePassword,
              focused: _passwordFocus.hasFocus,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Password tidak boleh kosong'
                : null,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            LoginErrorBanner(_errorMessage!),
          ],
          const SizedBox(height: 27),
          GradientLoginButton(
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _login,
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              'Akses khusus tim operasional',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: .9),
                fontSize: 10.5,
                letterSpacing: .15,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
