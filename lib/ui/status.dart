import 'package:flutter/material.dart';

import 'forms.dart';
import 'motion.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

/// Chip status. Selalu membawa ikon + teks (tidak bergantung pada warna
/// saja). Jika [onTap] diisi, chip bisa diketuk dan menampilkan panah.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.level,
    this.onTap,
    this.icon,
  });

  final String label;
  final StatusLevel level;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Status sparepart: ready / order_eo / back_order.
  factory StatusChip.sparepart(
    String status, {
    Key? key,
    VoidCallback? onTap,
    String prefix = '',
  }) {
    String text;
    switch (status) {
      case 'ready':
        text = 'Ready';
        break;
      case 'order_eo':
        text = 'Order EO';
        break;
      case 'back_order':
        text = 'Back Order';
        break;
      default:
        text = status;
    }
    return StatusChip(
      key: key,
      label: '$prefix$text',
      level: AppColors.levelOfValue(status),
      onTap: onTap,
    );
  }

  /// Status SPK asuransi: disetujui / proses_klaim / bermasalah.
  factory StatusChip.spk(
    String status, {
    Key? key,
    VoidCallback? onTap,
    String prefix = '',
  }) {
    String text;
    switch (status) {
      case 'disetujui':
        text = 'Disetujui';
        break;
      case 'proses_klaim':
        text = 'Proses Klaim';
        break;
      case 'bermasalah':
        text = 'Bermasalah';
        break;
      default:
        text = status;
    }
    return StatusChip(
      key: key,
      label: '$prefix$text',
      level: AppColors.levelOfValue(status),
      onTap: onTap,
    );
  }

  static IconData _iconFor(StatusLevel level) {
    switch (level) {
      case StatusLevel.good:
        return Icons.check_circle_rounded;
      case StatusLevel.warn:
        return Icons.schedule_rounded;
      case StatusLevel.bad:
        return Icons.error_rounded;
      case StatusLevel.info:
        return Icons.build_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = AppColors.status(level);

    final chip = AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.out,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pal.bg,
        borderRadius: BorderRadius.circular(AppRadius.chip + 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? _iconFor(level), size: 14, color: pal.fg),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            style: AppText.label.copyWith(
              color: pal.fg,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: pal.fg),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;
    return Pressable(scale: 0.94, onTap: onTap, child: chip);
  }
}

/// Satu pilihan status (nilai database, judul, deskripsi, skala SMART).
class StatusOption {
  final String value;
  final String title;
  final String desc;
  final int skala;
  const StatusOption(this.value, this.title, this.desc, this.skala);
}

/// Kartu pilihan untuk satu [StatusOption]. Pilihan aktif berganti dengan
/// transisi warna dan ikon centang yang membal.
class StatusOptionTile extends StatelessWidget {
  const StatusOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final StatusOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.out,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.sageSoft : AppColors.canvas,
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.line,
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: AppMotion.base,
              switchInCurve: AppMotion.spring,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(selected),
                color: selected ? AppColors.brand : AppColors.hint,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: AppText.subheading),
                  const SizedBox(height: 2),
                  Text(option.desc, style: AppText.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Text('Skala ${option.skala}', style: AppText.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan bottom sheet "Ubah status ..." (handle, judul, daftar pilihan,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, style: AppText.heading.copyWith(fontSize: 19)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppText.bodyMuted),
              const SizedBox(height: 18),
              for (var i = 0; i < options.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 70 * i),
                  dy: 0.12,
                  child: StatusOptionTile(
                    option: options[i],
                    selected: selected == options[i].value,
                    onTap: () => onSelect(options[i].value),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Setelah disimpan, ranking dihitung ulang otomatis.',
                style: AppText.caption,
              ),
              const SizedBox(height: 16),
              CancelSaveButtons(
                isSaving: isSaving,
                onCancel: onCancel,
                onSave: onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
