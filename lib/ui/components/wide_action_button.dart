import 'package:flutter/material.dart';

/// Tombol primary lebar penuh (tinggi 54) di bawah halaman detail.
/// [onPressed] null = tombol nonaktif.
class WideActionButton extends StatelessWidget {
  const WideActionButton({
    super.key,
    required this.label,
    required this.isProcessing,
    required this.onPressed,
  });

  final String label;
  final bool isProcessing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: isProcessing
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
      ),
    );
  }
}
