import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme/app_effects.dart';
import 'theme/app_colors.dart';
import 'theme/app_text.dart';

/// Satu tujuan pada [AppBottomNav].
class BottomNavItem<T> {
  const BottomNavItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.count,
    this.badgeColor,
  });

  final T value;
  final String label;

  /// Ikon saat tidak dipilih (outline) dan saat dipilih (solid).
  final IconData icon;
  final IconData activeIcon;

  /// Jumlah yang ditampilkan sebagai lencana di atas ikon. Disembunyikan
  /// kalau null atau 0.
  final int? count;

  /// Warna lencana. Default: teal [AppColors.brand] saat dipilih,
  /// [AppColors.muted] saat tidak.
  final Color? badgeColor;
}

/// Navigasi bawah: ikon + label + lencana jumlah. Penanda pilihan berupa
/// pil lembut di belakang ikon yang meluncur halus (AppMotion).
///
/// Dipasang di `Scaffold.bottomNavigationBar`.
class AppBottomNav<T> extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.items,
    required this.onChanged,
    this.maxWidth = 900,
  });

  final T current;
  final List<BottomNavItem<T>> items;
  final ValueChanged<T> onChanged;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        // Bukan AppContent: Center miliknya mengisi seluruh tinggi yang
        // tersedia, sedangkan bar ini harus setinggi isinya saja.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: _NavTile(
                        item: item,
                        selected: item.value == current,
                        onTap: () => onChanged(item.value),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile<T> extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final BottomNavItem<T> item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brandDeep : AppColors.muted;
    final count = item.count ?? 0;

    return Pressable(
      scale: 0.94,
      onTap: onTap,
      child: Semantics(
        selected: selected,
        label: count > 0 ? '${item.label}, $count unit' : item.label,
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: AppMotion.base,
                  curve: AppMotion.out,
                  width: 52,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.infoBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    size: 22,
                    color: color,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -2,
                    child: _CountBadge(
                      count: count,
                      color: item.badgeColor ??
                          (selected ? AppColors.brand : AppColors.muted),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.base,
                style: AppText.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(item.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.card, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppText.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}