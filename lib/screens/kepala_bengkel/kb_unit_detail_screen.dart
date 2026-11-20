import 'package:flutter/material.dart';

import '../../logic/smart_calculator.dart';
import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
import '../../utils/wip_format.dart';
import 'kb_dashboard_screen.dart' show confirmSelesai;

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

  Future<void> _selesaikanUnit() async {
    final ok = await confirmSelesai(context, widget.unit.noWO);
    if (ok != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await _repo.selesaikanUnit(widget.unit.id);
      if (mounted) {
        showAppSnackbar(
          context,
          '${widget.unit.noWO} selesai, ranking diperbarui.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Gagal menandai selesai: $e',
          kind: SnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _terbitkanInstruksi() async {
    setState(() => _isProcessing = true);
    try {
      await _repo.terbitkanInstruksi(widget.unit.id);
      if (mounted) {
        showAppSnackbar(
          context,
          'Instruksi diterbitkan untuk ${widget.unit.noWO}',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Gagal menerbitkan instruksi: $e',
          kind: SnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final entry = widget.entry;
    final siap = isSiapDikerjakan(
      statusSparepart: unit.statusSparepart,
      statusSpkAsuransi: unit.statusSpkAsuransi,
    );

    final criteria = <CriteriaRow>[
      CriteriaRow(
        kode: 'C1',
        label: 'Panel',
        rawText: '${unit.jumlahPanel} panel',
        sifat: 'Cost',
        bobot: BobotKriteria.c1,
        utility: entry.uC1,
      ),
      CriteriaRow(
        kode: 'C2',
        label: 'Sparepart',
        rawText: '${labelSparepart(unit.statusSparepart)} (${unit.nilaiC2})',
        sifat: 'Benefit',
        bobot: BobotKriteria.c2,
        utility: entry.uC2,
      ),
      CriteriaRow(
        kode: 'C3',
        label: 'SPK Asuransi',
        rawText: '${labelSpk(unit.statusSpkAsuransi)} (${unit.nilaiC3})',
        sifat: 'Benefit',
        bobot: BobotKriteria.c3,
        utility: entry.uC3,
      ),
      CriteriaRow(
        kode: 'C4',
        label: 'Aging',
        rawText: '${unit.agingHari} hari',
        sifat: 'Benefit',
        bobot: BobotKriteria.c4,
        utility: entry.uC4,
      ),
      CriteriaRow(
        kode: 'C5',
        label: 'Biaya',
        rawText: 'Rp ${formatRupiah(unit.estimasiBiaya)}',
        sifat: 'Cost',
        bobot: BobotKriteria.c5,
        utility: entry.uC5,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DetailHeader(
              peringkat: entry.peringkat,
              tipeKendaraan: unit.tipeKendaraan,
              noWO: unit.noWO,
            ),
          ),
          SliverToBoxAdapter(
            child: AppContent(
              maxWidth: 780,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScoreSummary(value: entry.nilaiUi, siap: siap),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 220),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.sageSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.card.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline_rounded,
                                color: AppColors.brandDeep,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rekomendasi',
                                    style: AppText.subheading,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    rekomendasiText(
                                      peringkat: entry.peringkat,
                                      totalUnit: widget.totalUnit,
                                      statusSparepart: unit.statusSparepart,
                                      statusSpkAsuransi: unit.statusSpkAsuransi,
                                      jumlahPanel: unit.jumlahPanel,
                                      agingHari: unit.agingHari,
                                      statusPengerjaan: unit.statusPengerjaan,
                                    ),
                                    style: AppText.bodyMuted.copyWith(
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Rincian kriteria',
                      style: AppText.heading.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kontribusi setiap faktor terhadap prioritas unit.',
                      style: AppText.bodyMuted,
                    ),
                    const SizedBox(height: 12),

                    ...criteria.asMap().entries.map(
                      (e) => CriteriaTile(criteria: e.value, index: e.key),
                    ),

                    const SizedBox(height: 8),
                    TotalScoreCard(nilaiUi: entry.nilaiUi),

                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 600),
                      child: WideActionButton(
                        icon: unit.statusPengerjaan == 'sedang_dikerjakan'
                            ? Icons.check_circle_outline_rounded
                            : Icons.assignment_turned_in_rounded,
                        isProcessing: _isProcessing,
                        onPressed: _isProcessing
                            ? null
                            : unit.statusPengerjaan == 'menunggu'
                            ? (siap ? _terbitkanInstruksi : null)
                            : unit.statusPengerjaan == 'sedang_dikerjakan'
                            ? _selesaikanUnit
                            : null,
                        label: unit.statusPengerjaan == 'menunggu'
                            ? 'Terbitkan instruksi teknisi'
                            : unit.statusPengerjaan == 'sedang_dikerjakan'
                            ? 'Tandai selesai'
                            : 'Status: ${labelPengerjaan(unit.statusPengerjaan)}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
