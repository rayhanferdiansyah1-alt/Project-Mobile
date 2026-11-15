import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_role_service.dart';
import 'motion.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

/// Tombol ikon bulat kecil di header. Saat [isLoading] ikon berganti
/// mulus menjadi spinner.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.88,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.base,
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brand,
                  ),
                )
              : Icon(
                  icon,
                  key: const ValueKey('icon'),
                  size: 19,
                  color: AppColors.brandDeep,
                ),
        ),
      ),
    );
  }
}

/// Tombol kembali bulat di header halaman dalam.
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      icon: Icons.arrow_back_rounded,
      onTap: () => Navigator.pop(context),
    );
  }
}

/// Header generik: blok sage dengan sudut bawah membulat, label kecil,
/// judul besar, dan keterangan. Teksnya muncul bertahap saat halaman dibuka.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.extra,
    this.leading,
    this.actions = const <Widget>[],
    this.bottomPadding = 24,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? extra;
  final Widget? leading;
  final List<Widget> actions;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 12, 16, bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.header),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Expanded(
                child: Text(
                  eyebrow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(color: AppColors.brandDeep),
                ),
              ),
              ...actions.expand<Widget>(
                (w) => <Widget>[const SizedBox(width: 8), w],
              ),
            ],
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Text(title, style: AppText.title.copyWith(fontSize: 27)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: Text(subtitle!, style: AppText.bodyMuted),
            ),
          ],
          if (extra != null) ...[
            const SizedBox(height: 8),
            FadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: extra!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Header dashboard Kepala Bengkel: ringkasan jumlah unit (angka berhitung
/// naik), waktu hitung ranking, tombol hitung ulang, dan menu user.
class KbHeader extends StatelessWidget {
  const KbHeader({
    super.key,
    required this.totalUnit,
    required this.siapCount,
    required this.ditahanCount,
    required this.dihitungPada,
    required this.isRecomputing,
    required this.onRefresh,
  });

  final int totalUnit;
  final int siapCount;
  final int ditahanCount;
  final DateTime? dihitungPada;
  final bool isRecomputing;
  final VoidCallback onRefresh;

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _waktu(DateTime t) {
    final jam = t.hour.toString().padLeft(2, '0');
    final menit = t.minute.toString().padLeft(2, '0');
    return '${t.day} ${_bulan[t.month - 1]} ${t.year}, $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dihitung = dihitungPada;

    return AppHeader(
      eyebrow: 'Kepala bengkel · ${now.day} ${_bulan[now.month - 1]} ${now.year}',
      title: 'Prioritas unit',
      actions: [
        HeaderIconButton(
          icon: Icons.refresh_rounded,
          isLoading: isRecomputing,
          onTap: onRefresh,
        ),
        const AppUserMenu(),
      ],
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _SummaryStat(value: totalUnit, label: 'unit'),
              _SummaryStat(
                value: siapCount,
                label: 'siap',
                dot: AppColors.success,
              ),
              _SummaryStat(
                value: ditahanCount,
                label: 'ditahan',
                dot: AppColors.warning,
              ),
            ],
          ),
          if (dihitung != null) ...[
            const SizedBox(height: 6),
            Text(
              'Ranking dihitung ${_waktu(dihitung)}',
              style: AppText.caption,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label, this.dot});

  final int value;
  final String label;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot != null) ...[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
          const SizedBox(width: 6),
        ],
        CountUpText(value, style: AppText.subheading),
        const SizedBox(width: 4),
        Text(label, style: AppText.bodyMuted),
      ],
    );
  }
}

/// Header dashboard Service Advisor. [bottomPadding] besar karena kolom
/// pencarian menimpa tepi bawahnya.
class SaHeader extends StatelessWidget {
  const SaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHeader(
      eyebrow: 'Service advisor',
      title: 'Data unit WIP',
      subtitle: 'Kelola unit kendaraan yang masuk bengkel',
      actions: [AppUserMenu()],
      bottomPadding: 46,
    );
  }
}

/// Header dashboard Partman / staf asuransi.
class PartmanHeader extends StatelessWidget {
  const PartmanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHeader(
      eyebrow: 'Partman · staf asuransi',
      title: 'Status unit WIP',
      subtitle: 'Ketuk status untuk mengubahnya',
      actions: [AppUserMenu()],
    );
  }
}

/// Header form tambah / edit unit (Service Advisor).
class FormHeader extends StatelessWidget {
  const FormHeader({super.key, required this.isEditMode});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      eyebrow: 'Service advisor',
      title: isEditMode ? 'Edit unit WIP' : 'Tambah unit WIP',
      subtitle: 'Lengkapi data kendaraan yang masuk bengkel',
      leading: const HeaderBackButton(),
    );
  }
}

/// Header halaman detail unit (Kepala Bengkel).
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.peringkat,
    required this.tipeKendaraan,
    required this.noWO,
  });

  final int peringkat;
  final String tipeKendaraan;
  final String noWO;

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      eyebrow: 'Peringkat $peringkat',
      title: tipeKendaraan,
      extra: Text(noWO, style: AppText.mono),
      leading: const HeaderBackButton(),
      bottomPadding: 30,
    );
  }
}

/// Avatar inisial di header; ketuk membuka menu berisi nama, role, Logout.
class AppUserMenu extends StatefulWidget {
  const AppUserMenu({super.key});

  @override
  State<AppUserMenu> createState() => _AppUserMenuState();
}

class _AppUserMenuState extends State<AppUserMenu> {
  Future<UserProfile?>? _future;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) _future = UserRoleService().getProfile(user.uid);
  }

  String _labelRole(String level) {
    switch (level) {
      case 'service_advisor':
        return 'Service Advisor';
      case 'partman':
        return 'Partman / Staf Asuransi';
      case 'kepala_bengkel':
        return 'Kepala Bengkel';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) return const SizedBox.shrink();

    return FutureBuilder<UserProfile?>(
      future: future,
      builder: (context, snapshot) {
        final nama = snapshot.data?.nama ?? '...';
        final level = snapshot.data?.level ?? '';
        final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

        return PopupMenuButton<String>(
          offset: const Offset(0, 46),
          tooltip: 'Akun',
          padding: EdgeInsets.zero,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: Text(
              inisial,
              style: AppText.subheading.copyWith(color: Colors.white),
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nama, style: AppText.subheading),
                  Text(_labelRole(level), style: AppText.caption),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppColors.dangerText,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Keluar',
                    style: AppText.body.copyWith(color: AppColors.dangerText),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') FirebaseAuth.instance.signOut();
          },
        );
      },
    );
  }
}
