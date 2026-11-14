import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Dekorasi field email di halaman login (isi tipis warna primary, garis primary).
InputDecoration emailInputDecoration(BuildContext context) {
  final primary = Theme.of(context).colorScheme.primary;
  return InputDecoration(
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
    ),
    prefixIcon: Icon(
      Icons.mail_outline,
      color: primary,
      size: 21,
    ),
    filled: true,
    fillColor: primary.withValues(alpha: 0.035),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: primary.withValues(alpha: 0.35),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: primary.withValues(alpha: 0.35),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.redAccent,
      ),
    ),
  );
}

/// Dekorasi field kata sandi (abu polos, ikon mata untuk tampil/sembunyi).
InputDecoration passwordInputDecoration(
  BuildContext context, {
  required bool obscure,
  required VoidCallback onToggle,
}) {
  final primary = Theme.of(context).colorScheme.primary;
  return InputDecoration(
    prefixIcon: const Icon(
      Icons.lock_outline,
      color: AppColors.muted,
      size: 21,
    ),
    suffixIcon: IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.muted,
      ),
      onPressed: onToggle,
    ),
    filled: true,
    fillColor: AppColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.redAccent,
      ),
    ),
  );
}
