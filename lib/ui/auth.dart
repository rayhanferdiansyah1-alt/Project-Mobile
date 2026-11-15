import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

/// Bagian atas halaman login: lingkaran sage lembut (datar, tanpa blur),
/// monogram, judul aplikasi. Tiap elemen masuk bergiliran.
class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 300 + top,
      child: Stack(
        children: [
          const Positioned(
            right: -70,
            top: -60,
            child: _SoftCircle(size: 240, color: AppColors.sage),
          ),
          Positioned(
            right: 40,
            top: top + 78,
            child: const _SoftCircle(size: 56, color: AppColors.sageSoft),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(28, top + 48, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'PP',
                      style: AppText.heading.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Text(
                    'Prabu Pura Motor Karawang',
                    style: AppText.label,
                  ),
                ),
                const SizedBox(height: 6),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text('SPK WIP\nBodi dan Cat', style: AppText.display),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: Text(
                    'Workshop decision support system',
                    style: AppText.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: AppMotion.out,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0).toDouble(),
        child: Transform.scale(scale: v, child: child),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Judul + sub-judul "Selamat datang" di atas form login.
class LoginGreeting extends StatelessWidget {
  const LoginGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selamat datang', style: AppText.title.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text('Gunakan akun yang diberikan bengkel.', style: AppText.bodyMuted),
      ],
    );
  }
}

/// Label kecil di atas tiap field login.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.label.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

InputDecoration _authDecoration({
  required String hint,
  required IconData prefix,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.body.copyWith(color: AppColors.hint),
    prefixIcon: Icon(prefix, size: 20),
    prefixIconColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.focused)
          ? AppColors.brand
          : AppColors.muted,
    ),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.card,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: border(AppColors.line),
    enabledBorder: border(AppColors.line),
    focusedBorder: border(AppColors.brand, 1.6),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.6),
    errorStyle: AppText.caption.copyWith(color: AppColors.dangerText),
  );
}

/// Dekorasi field email di halaman login.
InputDecoration emailInputDecoration() {
  return _authDecoration(
    hint: 'nama@perusahaan.co.id',
    prefix: Icons.mail_outline_rounded,
  );
}

/// Dekorasi field kata sandi, dengan ikon mata untuk tampil/sembunyi.
InputDecoration passwordInputDecoration({
  required bool obscure,
  required VoidCallback onToggle,
}) {
  return _authDecoration(
    hint: 'Kata sandi',
    prefix: Icons.lock_outline_rounded,
    suffix: IconButton(
      onPressed: onToggle,
      icon: AnimatedSwitcher(
        duration: AppMotion.fast,
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          key: ValueKey(obscure),
          color: AppColors.muted,
          size: 20,
        ),
      ),
    ),
  );
}

/// Kotak pesan error di bawah field login; masuk dengan fade + naik tipis.
class LoginErrorBanner extends StatelessWidget {
  const LoginErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      dy: 0.2,
      duration: AppMotion.base,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.dangerText,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppText.label.copyWith(color: AppColors.dangerText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
