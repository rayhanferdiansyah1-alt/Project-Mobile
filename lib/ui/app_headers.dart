import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'shared_widgets.dart';

class CurveClipper extends CustomClipper<Path> {
  const CurveClipper(this.depth);
  final double depth;

  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - depth)
    ..quadraticBezierTo(
      size.width * .5,
      size.height + depth,
      size.width,
      size.height - depth,
    )
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant CurveClipper oldClipper) =>
      oldClipper.depth != depth;
}

class _CurveBorderPainter extends CustomPainter {
  const _CurveBorderPainter(this.depth);
  final double depth;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - depth)
        ..quadraticBezierTo(
          size.width * .5,
          size.height,
          size.width,
          size.height - depth,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CurveBorderPainter oldDelegate) =>
      oldDelegate.depth != depth;
}

/// Quiet, architectural dark surface used by dashboard and form headers.
class CurvedHeader extends StatefulWidget {
  const CurvedHeader({
    super.key,
    required this.padding,
    required this.curveDepth,
    required this.child,
  });
  final EdgeInsets padding;
  final double curveDepth;
  final Widget child;
  @override
  State<CurvedHeader> createState() => _CurvedHeaderState();
}

class _CurvedHeaderState extends State<CurvedHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: CurveClipper(widget.curveDepth),
    child: CustomPaint(
      foregroundPainter: _CurveBorderPainter(widget.curveDepth),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.heroGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _ambientCtrl,
                  builder: (context, _) => CustomPaint(
                    painter: _HeaderLinesPainter(_ambientCtrl.value),
                  ),
                ),
              ),
            ),
            Padding(padding: widget.padding, child: widget.child),
          ],
        ),
      ),
    ),
  );
}

class _HeaderLinesPainter extends CustomPainter {
  const _HeaderLinesPainter(this.phase);
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final x = size.width * (.74 + .03 * math.sin(phase * math.pi * 2));
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(x, size.height * .24),
        36.0 + i * 23,
        paint..color = AppColors.accent.withValues(alpha: .12 - i * .018),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderLinesPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class RoleBadge extends StatelessWidget {
  const RoleBadge(
    this.text, {
    super.key,
    this.horizontal = 12,
    this.vertical = 6,
    this.radius = 20,
    this.fontSize = 10.5,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 1,
  });
  const RoleBadge.hero(this.text, {super.key})
    : horizontal = 14,
      vertical = 7,
      radius = 24,
      fontSize = 10,
      fontWeight = FontWeight.w700,
      letterSpacing = 1.1;
  final String text;
  final double horizontal, vertical, radius, fontSize, letterSpacing;
  final FontWeight fontWeight;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .1),
      border: Border.all(color: Colors.white.withValues(alpha: .22)),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.onHeaderMuted,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    ),
  );
}

class HeaderTitle extends StatelessWidget {
  const HeaderTitle(this.text, {super.key, this.fontSize = 29});
  final String text;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: AppColors.onHeaderPrimary,
      fontSize: fontSize,
      height: 1.12,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.7,
    ),
  );
}

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
  final int totalUnit, siapCount, ditahanCount;
  final DateTime? dihitungPada;
  final bool isRecomputing;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${now.day} ${_bulan(now.month)} ${now.year}';
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF202923),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.amberBright,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'RUANG KERJA  /  KARAWANG',
                      style: TextStyle(
                        color: AppColors.onHeaderMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isRecomputing ? null : onRefresh,
                    tooltip: 'Hitung ulang ranking',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.surface,
                      backgroundColor: Colors.white.withValues(alpha: .08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: .12),
                        ),
                      ),
                    ),
                    icon: AnimatedRotation(
                      turns: isRecomputing ? 1 : 0,
                      duration: const Duration(milliseconds: 650),
                      child: const Icon(Icons.refresh_rounded, size: 19),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AppUserMenu(),
                ],
              ),
              const SizedBox(height: 23),
              const Text(
                'KEPALA BENGKEL',
                style: TextStyle(
                  color: AppColors.amberBright,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Antrean prioritas',
                style: TextStyle(
                  color: AppColors.onHeaderPrimary,
                  fontSize: 29,
                  height: 1.12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Bodi & cat  ·  $date',
                style: const TextStyle(
                  color: AppColors.onHeaderMuted,
                  fontSize: 12,
                ),
              ),
              if (dihitungPada != null) ...[
                const SizedBox(height: 3),
                Text(
                  'Ranking diperbarui ${_waktu(dihitungPada!)}',
                  style: TextStyle(
                    color: AppColors.onHeaderMuted.withValues(alpha: .72),
                    fontSize: 10.5,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .055),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: .1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _KbHeaderMetric(
                        value: '$totalUnit',
                        label: 'UNIT WIP',
                        color: AppColors.onHeaderPrimary,
                      ),
                    ),
                    _metricDivider(),
                    Expanded(
                      child: _KbHeaderMetric(
                        value: '$siapCount',
                        label: 'SIAP',
                        color: AppColors.successBright,
                      ),
                    ),
                    _metricDivider(),
                    Expanded(
                      child: _KbHeaderMetric(
                        value: '$ditahanCount',
                        label: 'DITAHAN',
                        color: AppColors.amberBright,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricDivider() => Container(
    width: 1,
    height: 31,
    color: Colors.white.withValues(alpha: .13),
  );

  String _waktu(DateTime d) =>
      '${d.day} ${_bulan(d.month)}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _bulan(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][m - 1];
}

class _KbHeaderMetric extends StatelessWidget {
  const _KbHeaderMetric({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 22,
          height: 1,
          fontWeight: FontWeight.w600,
          letterSpacing: -.6,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          color: AppColors.onHeaderMuted.withValues(alpha: .82),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}

class PartmanHeader extends StatelessWidget {
  const PartmanHeader({super.key});
  @override
  Widget build(BuildContext context) => const CurvedHeader(
    padding: EdgeInsets.fromLTRB(22, 58, 22, 48),
    curveDepth: 28,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [RoleBadge('PARTMAN / STAF ASURANSI'), AppUserMenu()],
        ),
        SizedBox(height: 28),
        Text(
          'OPERATIONS',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8),
        HeaderTitle('Status unit WIP'),
        SizedBox(height: 6),
        Text(
          'Pantau komponen dan persetujuan sebelum unit masuk proses.',
          style: TextStyle(color: AppColors.onHeaderMuted, fontSize: 12.5),
        ),
      ],
    ),
  );
}

class SaHeader extends StatelessWidget {
  const SaHeader({super.key});
  @override
  Widget build(BuildContext context) => const CurvedHeader(
    padding: EdgeInsets.fromLTRB(22, 58, 22, 48),
    curveDepth: 28,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [RoleBadge('SERVICE ADVISOR'), AppUserMenu()],
        ),
        SizedBox(height: 28),
        Text(
          'WORKSHOP INTAKE',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8),
        HeaderTitle('Data unit WIP'),
        SizedBox(height: 6),
        Text(
          'Kelola kendaraan yang masuk ke bengkel.',
          style: TextStyle(color: AppColors.onHeaderMuted, fontSize: 12.5),
        ),
      ],
    ),
  );
}

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.peringkat,
    required this.tipeKendaraan,
    required this.noWO,
  });
  final int peringkat;
  final String tipeKendaraan, noWO;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF202923),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kembali',
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.surface,
                    backgroundColor: Colors.white.withValues(alpha: .08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .12),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 19),
                ),
                const SizedBox(width: 12),
                const Text(
                  'RINCIAN UNIT',
                  style: TextStyle(
                    color: AppColors.onHeaderMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${peringkat.toString().padLeft(2, '0')} / PRIORITAS',
                  style: const TextStyle(
                    color: AppColors.amberBright,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Text(
              tipeKendaraan,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onHeaderPrimary,
                fontSize: 27,
                height: 1.1,
                fontWeight: FontWeight.w600,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'WORK ORDER  /  $noWO',
              style: const TextStyle(
                color: AppColors.onHeaderMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: .65,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class FormHeader extends StatelessWidget {
  const FormHeader({super.key, required this.isEditMode});
  final bool isEditMode;
  @override
  Widget build(BuildContext context) => CurvedHeader(
    padding: const EdgeInsets.fromLTRB(16, 52, 20, 38),
    curveDepth: 22,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => Navigator.pop(context),
              tooltip: 'Kembali',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .1),
                foregroundColor: AppColors.surface,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            const RoleBadge('SERVICE ADVISOR'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          isEditMode ? 'PERBARUI DATA' : 'PENERIMAAN UNIT',
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        HeaderTitle(
          isEditMode ? 'Edit unit WIP' : 'Tambah unit WIP',
          fontSize: 27,
        ),
      ],
    ),
  );
}
