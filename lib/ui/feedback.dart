import 'package:flutter/material.dart';

import '../models/unit_wip.dart';
import 'forms.dart';
import 'motion.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

enum SnackKind { success, error, info }

/// Snackbar melayang bergaya kartu: ikon bulat berwarna + pesan.
void showAppSnackbar(
  BuildContext context,
  String message, {
  SnackKind kind = SnackKind.success,
}) {
  final StatusLevel level;
  final IconData icon;
  switch (kind) {
    case SnackKind.success:
      level = StatusLevel.good;
      icon = Icons.check_rounded;
      break;
    case SnackKind.error:
      level = StatusLevel.bad;
      icon = Icons.priority_high_rounded;
      break;
    case SnackKind.info:
      level = StatusLevel.info;
      icon = Icons.info_outline_rounded;
      break;
  }
  final pal = AppColors.status(level);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        content: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: pal.bg, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: pal.fill),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppText.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
}

/// Dialog konfirmasi hapus unit WIP.
class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({
    super.key,
    required this.unit,
    required this.onConfirm,
  });

  final UnitWip unit;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 27,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hapus unit ini?',
              style: AppText.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${unit.noWO} (${unit.tipeKendaraan}) akan dihapus dari daftar WIP, '
              'lalu ranking dihitung ulang. Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    variant: AppButtonVariant.outline,
                    height: 46,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Hapus',
                    variant: AppButtonVariant.danger,
                    height: 46,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan [DeleteConfirmDialog] dengan animasi membesar + fade.
Future<void> showDeleteConfirmDialog(
  BuildContext context, {
  required UnitWip unit,
  required VoidCallback onConfirm,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: AppColors.ink.withValues(alpha: 0.35),
    transitionDuration: AppMotion.base,
    pageBuilder: (ctx, animation, secondary) =>
        DeleteConfirmDialog(unit: unit, onConfirm: onConfirm),
    transitionBuilder: (ctx, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.spring,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Tampilan kosong: ikon yang membal masuk + judul + keterangan.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: AppMotion.spring,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.sage,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppColors.brandDeep),
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppText.heading,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppText.bodyMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kerangka kartu yang berdenyut pelan, pengganti spinner saat data dimuat.
class SkeletonList extends StatefulWidget {
  const SkeletonList({
    super.key,
    this.count = 4,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
  });

  final int count;
  final EdgeInsets padding;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.45,
    end: 1,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lineSoft,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Padding(
        padding: widget.padding,
        child: Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: appCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(150, 16),
                    const SizedBox(height: 8),
                    _bar(96, 11),
                    const SizedBox(height: 20),
                    _bar(double.infinity, 12),
                    const SizedBox(height: 10),
                    _bar(220, 12),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan memuat satu halaman penuh: blok header kosong + kerangka kartu.
class PageSkeleton extends StatelessWidget {
  const PageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 170 + top,
            decoration: const BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.header),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SkeletonList(),
        ],
      ),
    );
  }
}
