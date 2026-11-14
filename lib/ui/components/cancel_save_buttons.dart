import 'package:flutter/material.dart';

/// Pasangan tombol Batal (outline) + Simpan (primary) di bottom sheet dan form.
/// Saat [isSaving] true kedua tombol nonaktif dan Simpan menampilkan spinner.
class CancelSaveButtons extends StatelessWidget {
  const CancelSaveButtons({
    super.key,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    this.saveFlex = 1,
    this.boldSaveLabel = false,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final int saveFlex;
  final bool boldSaveLabel;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: saveFlex,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: boldSaveLabel ? FontWeight.w700 : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
