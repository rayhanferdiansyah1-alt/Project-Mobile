import 'package:flutter/material.dart';

import '../theme/app_effects.dart';

class PillTabItem<T> {
  const PillTabItem(this.value, this.label);

  final T value;
  final String label;
}

/// Tab pill putih dengan indikator warna primary. Menggantikan dua
/// `_FilterTabs` kembar (Partman 2 tab, Kepala Bengkel 4 tab).
/// [fitLabels] = true membungkus label dengan FittedBox (dipakai Kepala Bengkel
/// karena 4 tab, supaya teks mengecil alih-alih terpotong).
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.current,
    required this.items,
    required this.onChanged,
    this.fitLabels = false,
  });

  final T current;
  final List<PillTabItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool fitLabels;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget tab(PillTabItem<T> item) {
      final selected = current == item.value;
      final label = Text(
        item.label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey.shade600,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
      );
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(item.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: fitLabels
                ? FittedBox(fit: BoxFit.scaleDown, child: label)
                : label,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.pill,
      ),
      child: Row(children: items.map(tab).toList()),
    );
  }
}
