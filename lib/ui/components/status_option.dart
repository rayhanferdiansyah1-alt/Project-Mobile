import 'package:flutter/material.dart';

/// Satu pilihan status (nilai database, judul, deskripsi, skala SMART).
/// Dulu `_Option` ditulis dobel di sparepart_update_sheet dan spk_update_sheet.
class StatusOption {
  final String value;
  final String title;
  final String desc;
  final int skala;
  const StatusOption(this.value, this.title, this.desc, this.skala);
}

/// Kartu pilihan radio untuk satu [StatusOption].
class StatusOptionTile extends StatelessWidget {
  const StatusOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  final StatusOption option;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.06) : Colors.white,
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 1.6 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? primary : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(option.desc, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Skala ${option.skala}', style: const TextStyle(fontSize: 10.5)),
            ),
          ],
        ),
      ),
    );
  }
}
