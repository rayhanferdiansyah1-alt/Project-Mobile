import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

enum AppButtonVariant { primary, outline, danger }

/// Tombol utama aplikasi. Mengecil saat ditekan, dan berubah mulus menjadi
/// spinner saat [isLoading]. [onPressed] null = nonaktif (abu-abu), kecuali
/// sedang [isLoading] (tetap berwarna tapi tidak bisa ditekan).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.height = 52,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tappable = onPressed != null && !isLoading;
    final active = onPressed != null || isLoading;

    final Color bg;
    final Color fg;
    final Color? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = active ? AppColors.brand : AppColors.lineSoft;
        fg = active ? Colors.white : AppColors.hint;
        border = null;
        break;
      case AppButtonVariant.danger:
        bg = active ? AppColors.danger : AppColors.lineSoft;
        fg = active ? Colors.white : AppColors.hint;
        border = null;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = active ? AppColors.ink : AppColors.hint;
        border = AppColors.muted.withValues(alpha: active ? 0.4 : 0.2);
        break;
    }

    final Widget content = isLoading
        ? SizedBox(
            key: const ValueKey('loading'),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            key: const ValueKey('label'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.button.copyWith(color: fg)),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18, color: fg),
              ],
            ],
          );

    return Pressable(
      onTap: tappable ? onPressed : null,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.out,
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: expand ? 16 : 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(height >= 48 ? 16 : 14),
          border: border == null ? null : Border.all(color: border),
        ),
        child: AnimatedSize(
          duration: AppMotion.fast,
          child: AnimatedSwitcher(duration: AppMotion.fast, child: content),
        ),
      ),
    );
  }
}

/// Pasangan tombol Batal (outline) + Simpan di bottom sheet dan form.
/// Saat [isSaving] true kedua tombol nonaktif dan Simpan menampilkan spinner.
class CancelSaveButtons extends StatelessWidget {
  const CancelSaveButtons({
    super.key,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    this.saveFlex = 1,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final int saveFlex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Batal',
            variant: AppButtonVariant.outline,
            height: 50,
            onPressed: isSaving ? null : onCancel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: saveFlex,
          child: AppButton(
            label: 'Simpan',
            height: 50,
            isLoading: isSaving,
            onPressed: isSaving ? null : onSave,
          ),
        ),
      ],
    );
  }
}

/// Tombol primary lebar penuh di bawah halaman detail.
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
    return AppButton(
      label: label,
      height: 54,
      isLoading: isProcessing,
      onPressed: onPressed,
    );
  }
}

/// Tombol aksi mengambang berbentuk pil. Masuk dengan efek membal, dan
/// meluncur turun saat [visible] false (mis. saat daftar di-scroll ke bawah).
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.visible = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: AppMotion.spring,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 2),
        duration: AppMotion.base,
        curve: AppMotion.out,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppMotion.base,
          child: Pressable(
            onTap: visible ? onPressed : null,
            scale: 0.94,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppShadows.floating,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(label, style: AppText.button),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SegmentItem<T> {
  const SegmentItem(this.value, this.label, {this.count});

  final T value;
  final String label;
  final int? count;
}

/// Filter segmen dengan penanda yang meluncur ke pilihan aktif.
/// Menggantikan tab pill dan stat card (hitungan ikut tampil di label).
class SegmentFilter<T> extends StatelessWidget {
  const SegmentFilter({
    super.key,
    required this.current,
    required this.items,
    required this.onChanged,
  });

  final T current;
  final List<SegmentItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = items.length;
        final idx = items.indexWhere((e) => e.value == current);
        // 4 padding + 1 garis di tiap sisi.
        final cell = (constraints.maxWidth - 10) / n;

        return Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: appCardDecoration(radius: 24),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: AppMotion.base,
                curve: AppMotion.out,
                left: cell * (idx < 0 ? 0 : idx),
                top: 0,
                bottom: 0,
                width: cell,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: Pressable(
                        scale: 0.95,
                        onTap: () => onChanged(item.value),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedDefaultTextStyle(
                              duration: AppMotion.base,
                              style: AppText.label.copyWith(
                                fontSize: 12.5,
                                color: item.value == current
                                    ? Colors.white
                                    : AppColors.muted,
                                fontWeight: item.value == current
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              child: Text(
                                item.count == null
                                    ? item.label
                                    : '${item.label} ${item.count}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Kolom pencarian di dashboard Service Advisor, dengan tombol hapus yang
/// muncul saat ada teks.
class WipSearchBar extends StatelessWidget {
  const WipSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: appCardDecoration(radius: 18, shadow: AppShadows.soft),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppText.body.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari No. WO atau tipe kendaraan',
          hintStyle: AppText.body.copyWith(color: AppColors.hint),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.muted,
            size: 21,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: value.text.isEmpty
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : IconButton(
                        key: const ValueKey('clear'),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.muted,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Kotak berlabel untuk satu field di form unit. Garis dan label berubah
/// warna halus saat field di dalamnya difokuskan.
class FieldBox extends StatefulWidget {
  const FieldBox({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  State<FieldBox> createState() => _FieldBoxState();
}

class _FieldBoxState extends State<FieldBox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.out,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused ? AppColors.brand : AppColors.line,
            width: _focused ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppMotion.base,
              style: AppText.caption.copyWith(
                color: _focused ? AppColors.brand : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
              child: Text(widget.label),
            ),
            const SizedBox(height: 2),
            widget.child,
          ],
        ),
      ),
    );
  }
}

/// InputDecoration polos (tanpa garis) untuk field di dalam [FieldBox].
InputDecoration plainInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.body.copyWith(color: AppColors.hint),
    isDense: true,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(vertical: 6),
    errorStyle: AppText.caption.copyWith(color: AppColors.dangerText),
  );
}
