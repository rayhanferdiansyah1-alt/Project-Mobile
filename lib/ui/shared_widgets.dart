import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/unit_wip.dart';
import '../services/user_role_service.dart';
import '../utils/wip_format.dart';
import 'app_theme.dart';

class TapScale extends StatelessWidget {
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = .985,
    this.enableHaptic = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final bool enableHaptic;
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: 1,
    duration: const Duration(milliseconds: 120),
    child: child,
  );
}

class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({super.key, required this.index, required this.child});
  final int index;
  final Widget child;
  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> {
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      Duration(milliseconds: 35 * widget.index.clamp(0, 8)),
      () {
        if (mounted) setState(() => _visible = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _visible ? 1 : 0,
    duration: const Duration(milliseconds: 250),
    child: widget.child,
  );
}

class PulsingStatusDot extends StatelessWidget {
  const PulsingStatusDot({
    super.key,
    required this.color,
    this.size = 8,
    this.pulse = true,
  });
  final Color color;
  final double size;
  final bool pulse;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: pulse
          ? [BoxShadow(color: color.withValues(alpha: .2), blurRadius: 6)]
          : null,
    ),
  );
}

class AppUserMenu extends StatelessWidget {
  const AppUserMenu({super.key});
  String _labelRole(String level) => switch (level) {
    'service_advisor' => 'Service Advisor',
    'partman' => 'Partman / Staf Asuransi',
    'kepala_bengkel' => 'Kepala Bengkel',
    _ => level,
  };
  @override
  Widget build(BuildContext context) {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } on FirebaseException {
      return const SizedBox.shrink();
    }
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder<UserProfile?>(
      future: UserRoleService().getProfile(user.uid),
      builder: (context, snapshot) {
        final nama = snapshot.data?.nama ?? 'Akun';
        final level = snapshot.data?.level ?? '';
        final initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
        return PopupMenuButton<String>(
          tooltip: 'Menu akun',
          offset: const Offset(0, 48),
          color: AppColors.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          child: CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white.withValues(alpha: .12),
            foregroundColor: AppColors.surface,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _labelRole(level),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 17, color: AppColors.danger),
                  SizedBox(width: 9),
                  Text('Keluar', style: TextStyle(color: AppColors.dangerText)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              HapticFeedback.selectionClick();
              FirebaseAuth.instance.signOut();
            }
          },
        );
      },
    );
  }
}

class PillTabItem<T> {
  const PillTabItem(this.value, this.label);
  final T value;
  final String label;
}

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
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: items.map((item) {
          final selected = current == item.value;
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (!selected) {
                    HapticFeedback.selectionClick();
                    onChanged(item.value);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    style: TextStyle(
                      color: selected ? AppColors.surface : AppColors.textMuted,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    child: fitLabels
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(item.label, maxLines: 1),
                          )
                        : Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 5,
    required this.color,
    this.textColor,
    this.decimals = 3,
  });
  final double value, size, strokeWidth;
  final Color color;
  final Color? textColor;
  final int decimals;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0, 1)),
    duration: const Duration(milliseconds: 650),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: strokeWidth,
              backgroundColor: color.withValues(alpha: .14),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            idDecimal(v, decimals: decimals),
            style: TextStyle(
              fontSize: size * .21,
              fontWeight: FontWeight.w700,
              color: textColor ?? color,
            ),
          ),
        ],
      ),
    ),
  );
}

class ScoreSummary extends StatelessWidget {
  const ScoreSummary({super.key, required this.value, required this.siap});
  final double value;
  final bool siap;
  @override
  Widget build(BuildContext context) {
    final color = siap ? AppColors.success : AppColors.warningText;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NILAI PRIORITAS',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.35,
                        color: AppColors.onHeaderMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      idDecimal(value, decimals: 4),
                      style: const TextStyle(
                        color: AppColors.onHeaderPrimary,
                        fontSize: 30,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        siap
                            ? Icons.check_circle_outline
                            : Icons.hourglass_bottom_rounded,
                        color: color,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          siap ? 'Siap dikerjakan' : 'Menunggu kesiapan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) => LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: .12),
                valueColor: const AlwaysStoppedAnimation(AppColors.amberBright),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            siap
                ? 'Komponen utama tersedia untuk mulai dikerjakan.'
                : 'Selesaikan persyaratan sebelum unit masuk pengerjaan.',
            style: TextStyle(
              color: AppColors.onHeaderMuted.withValues(alpha: .82),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class CriteriaRow {
  CriteriaRow({
    required this.kode,
    required this.label,
    required this.rawText,
    required this.sifat,
    required this.bobot,
    required this.utility,
  });
  final String kode, label, rawText, sifat;
  final double bobot, utility;
  double get skor => bobot * utility;
}

class CriteriaTile extends StatelessWidget {
  const CriteriaTile({super.key, required this.criteria, required this.index});
  final CriteriaRow criteria;
  final int index;
  @override
  Widget build(BuildContext context) {
    final c = criteria;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                c.kode,
                style: const TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      c.rawText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    idDecimal(c.skor),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'KONTRIBUSI',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .7,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: c.utility.clamp(0, 1)),
                    duration: Duration(milliseconds: 420 + index * 70),
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, _) => LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(c.utility.clamp(0, 1) * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Utility ${idDecimal(c.utility, decimals: 3)}  ·  bobot ${idDecimal(c.bobot, decimals: 2)}  ·  ${c.sifat}',
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

enum StatusPillLevel { good, warn, bad }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.level,
    this.icon,
  });
  factory StatusPill.sparepart(String value) => StatusPill(
    label: labelSparepart(value),
    level: value == 'ready'
        ? StatusPillLevel.good
        : value == 'order_eo'
        ? StatusPillLevel.warn
        : StatusPillLevel.bad,
    icon: Icons.inventory_2_outlined,
  );
  factory StatusPill.spk(String value) => StatusPill(
    label: labelSpk(value),
    level: value == 'disetujui'
        ? StatusPillLevel.good
        : value == 'proses_klaim'
        ? StatusPillLevel.warn
        : StatusPillLevel.bad,
    icon: Icons.description_outlined,
  );
  final String label;
  final StatusPillLevel level;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      StatusPillLevel.good => AppColors.success,
      StatusPillLevel.warn => AppColors.warningText,
      StatusPillLevel.bad => AppColors.dangerText,
    };
    final bg = switch (level) {
      StatusPillLevel.good => AppColors.successSoft,
      StatusPillLevel.warn => AppColors.warningSoft,
      StatusPillLevel.bad => AppColors.dangerSoft,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusOption {
  const StatusOption(this.value, this.title, this.subtitle, this.score);
  final String value, title, subtitle;
  final int score;
}

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
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.accentDark : AppColors.textMuted,
              size: 19,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${option.score}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

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
  final String title, subtitle, selected;
  final List<StatusOption> options;
  final ValueChanged<String> onSelect;
  final bool isSaving;
  final VoidCallback onCancel, onSave;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    decoration: const BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ...options.map(
            (o) => StatusOptionTile(
              option: o,
              selected: o.value == selected,
              onTap: () => onSelect(o.value),
            ),
          ),
          const SizedBox(height: 8),
          CancelSaveButtons(
            isSaving: isSaving,
            onCancel: onCancel,
            onSave: onSave,
          ),
        ],
      ),
    ),
  );
}

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
  final VoidCallback onCancel, onSave;
  final int saveFlex;
  final bool boldSaveLabel;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: isSaving ? null : onCancel,
          child: const Text('Batal'),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: saveFlex,
        child: ElevatedButton(
          onPressed: isSaving ? null : onSave,
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.surface,
                  ),
                )
              : Text(
                  'Simpan',
                  style: TextStyle(
                    fontWeight: boldSaveLabel
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
        ),
      ),
    ],
  );
}

class WideActionButton extends StatelessWidget {
  const WideActionButton({
    super.key,
    required this.isProcessing,
    required this.onPressed,
    required this.label,
  });
  final bool isProcessing;
  final VoidCallback? onPressed;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: isProcessing ? null : onPressed,
      icon: isProcessing
          ? const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.surface,
              ),
            )
          : const Icon(Icons.assignment_turned_in_outlined, size: 18),
      label: Text(label, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: onPressed == null
            ? const Color(0xFFE9E7E0)
            : AppColors.primary,
        foregroundColor: onPressed == null
            ? AppColors.textMuted
            : AppColors.onHeaderPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({
    super.key,
    required this.unit,
    required this.onConfirm,
  });
  final UnitWip unit;
  final VoidCallback onConfirm;
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    icon: const Icon(
      Icons.delete_outline_rounded,
      color: AppColors.danger,
      size: 28,
    ),
    title: const Text(
      'Hapus unit?',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    content: Text(
      'Data ${unit.tipeKendaraan} dengan WO ${unit.noWO} akan dihapus.',
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textMuted, height: 1.4),
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
        child: const Text('Hapus'),
      ),
    ],
  );
}

class FieldBox extends StatefulWidget {
  const FieldBox({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  State<FieldBox> createState() => _FieldBoxState();
}

class _FieldBoxState extends State<FieldBox> {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: widget.child,
      ),
    ],
  );
}

InputDecoration plainInputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  contentPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 13),
);

class WipSearchBar extends StatefulWidget {
  const WipSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  State<WipSearchBar> createState() => _WipSearchBarState();
}

class _WipSearchBarState extends State<WipSearchBar> {
  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      hintText: 'Cari nomor WO atau kendaraan',
      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      suffixIcon: widget.controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Hapus pencarian',
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
                setState(() {});
              },
              icon: const Icon(Icons.close_rounded),
            ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
      ),
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
