import 'package:flutter/material.dart';

import '../../logic/smart_calculator.dart';
import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../utils/wip_format.dart';
import '../../widgets/score_ring.dart';

class KbUnitDetailScreen extends StatefulWidget {
  const KbUnitDetailScreen({
    super.key,
    required this.unit,
    required this.entry,
    required this.totalUnit,
  });

  final UnitWip unit;
  final RankingEntry entry;
  final int totalUnit;

  @override
  State<KbUnitDetailScreen> createState() => _KbUnitDetailScreenState();
}

class _KbUnitDetailScreenState extends State<KbUnitDetailScreen> {
  final _repo = UnitWipRepository();
  bool _isProcessing = false;

  Future<void> _terbitkanInstruksi() async {
    setState(() => _isProcessing = true);
    try {
      await _repo.updateUnitFields(widget.unit.id, {'statusPengerjaan': 'sedang_dikerjakan'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instruksi diterbitkan untuk ${widget.unit.noWO}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menerbitkan instruksi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final entry = widget.entry;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final siap = isSiapDikerjakan(
      statusSparepart: unit.statusSparepart,
      statusSpkAsuransi: unit.statusSpkAsuransi,
    );

    final criteria = <_CriteriaRow>[
      _CriteriaRow(
        kode: 'C1', label: 'Panel',
        rawText: '${unit.jumlahPanel} panel',
        sifat: 'Cost', bobot: BobotKriteria.c1, utility: entry.uC1,
      ),
      _CriteriaRow(
        kode: 'C2', label: 'Sparepart',
        rawText: '${labelSparepart(unit.statusSparepart)} (${unit.nilaiC2})',
        sifat: 'Benefit', bobot: BobotKriteria.c2, utility: entry.uC2,
      ),
      _CriteriaRow(
        kode: 'C3', label: 'SPK Asuransi',
        rawText: '${labelSpk(unit.statusSpkAsuransi)} (${unit.nilaiC3})',
        sifat: 'Benefit', bobot: BobotKriteria.c3, utility: entry.uC3,
      ),
      _CriteriaRow(
        kode: 'C4', label: 'Aging',
        rawText: '${unit.agingHari} hari',
        sifat: 'Benefit', bobot: BobotKriteria.c4, utility: entry.uC4,
      ),
      _CriteriaRow(
        kode: 'C5', label: 'Biaya',
        rawText: 'Rp ${formatRupiah(unit.estimasiBiaya)}',
        sifat: 'Cost', bobot: BobotKriteria.c5, utility: entry.uC5,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F4),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: _DetailHeaderClipper(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 52, 20, 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(primary, Colors.black, 0.1)!,
                      Color.lerp(primary, Colors.black, 0.4)!,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const CircleAvatar(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          radius: 16,
                          child: Text('KB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'PERINGKAT ${entry.peringkat}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      unit.tipeKendaraan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      unit.noWO,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ring skor besar + status
                  Transform.translate(
                    offset: const Offset(0, -46),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ScoreRing(
                            value: entry.nilaiUi,
                            size: 92,
                            strokeWidth: 8,
                            color: siap ? const Color(0xFF1F9D6B) : const Color(0xFFFF8A00),
                            decimals: 4,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: siap
                                ? const Color(0xFF1F9D6B).withValues(alpha: 0.12)
                                : const Color(0xFFFF8A00).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: siap ? const Color(0xFF1F9D6B) : const Color(0xFFFF8A00),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                siap ? 'Siap dikerjakan' : 'Ditahan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: siap ? const Color(0xFF1F9D6B) : const Color(0xFFB36B00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -34),
                    child: Text(
                      rekomendasiText(
                        peringkat: entry.peringkat,
                        totalUnit: widget.totalUnit,
                        statusSparepart: unit.statusSparepart,
                        statusSpkAsuransi: unit.statusSpkAsuransi,
                        jumlahPanel: unit.jumlahPanel,
                        agingHari: unit.agingHari,
                      ),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Rincian Kriteria',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF14181F)),
                  ),
                  const SizedBox(height: 12),

                  ...criteria.asMap().entries.map((e) {
                    final i = e.key;
                    final c = e.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + i * 100),
                      curve: Curves.easeOut,
                      builder: (context, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
                      ),
                      child: _CriteriaTile(criteria: c),
                    );
                  }),

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Ui',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text(
                              idDecimal(entry.nilaiUi),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: entry.nilaiUi.clamp(0, 1)),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: v,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Utility dihitung dari nilai maksimum dan minimum seluruh unit WIP aktif.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: (siap && unit.statusPengerjaan == 'menunggu' && !_isProcessing)
                          ? _terbitkanInstruksi
                          : null,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                          : Text(
                              unit.statusPengerjaan == 'menunggu'
                                  ? 'Terbitkan Instruksi Penugasan Teknisi'
                                  : 'Status: ${unit.statusPengerjaan}',
                              style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaRow {
  final String kode;
  final String label;
  final String rawText;
  final String sifat;
  final double bobot;
  final double utility;

  _CriteriaRow({
    required this.kode,
    required this.label,
    required this.rawText,
    required this.sifat,
    required this.bobot,
    required this.utility,
  });

  double get skor => bobot * utility;
}

class _CriteriaTile extends StatelessWidget {
  const _CriteriaTile({required this.criteria});
  final _CriteriaRow criteria;

  @override
  Widget build(BuildContext context) {
    final c = criteria;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${c.kode}  ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: '${c.label}: ${c.rawText}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Skor ${idDecimal(c.skor)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Utility ${idDecimal(c.utility, decimals: 3)} · bobot '
            '${idDecimal(c.bobot, decimals: 2)} · ${c.sifat}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: c.utility.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}