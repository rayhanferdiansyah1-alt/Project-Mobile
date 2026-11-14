import 'package:flutter/material.dart';

import 'cancel_save_buttons.dart';
import 'status_option.dart';

/// Tampilan bottom sheet "Ubah Status ..." (handle, judul, daftar pilihan,
/// tombol). Dipakai bersama oleh sheet Sparepart dan sheet SPK Asuransi;
/// state dan logika simpan tetap milik masing-masing sheet.
class StatusUpdateSheetView extends StatelessWidget {
  const StatusUpdateSheetView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final List<StatusOption> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ...options.map((o) => StatusOptionTile(
                  option: o,
                  selected: selected == o.value,
                  primary: primary,
                  onTap: () => onSelect(o.value),
                )),
            const SizedBox(height: 8),
            Text(
              'Setelah disimpan, ranking dihitung ulang otomatis.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            CancelSaveButtons(isSaving: isSaving, onCancel: onCancel, onSave: onSave),
          ],
        ),
      ),
    );
  }
}
