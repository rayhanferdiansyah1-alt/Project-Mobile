import 'package:flutter/material.dart';

import '../../logic/smart_calculator.dart';
import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
import '../../utils/wip_format.dart';

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
        showAppSnackbar(context, 'Instruksi diterbitkan untuk ${widget.unit.noWO}');
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
        kode: 'C1', label: 'Panel',
        rawText: '${unit.jumlahPanel} panel',
        sifat: 'Cost', bobot: BobotKriteria.c1, utility: entry.uC1,
      ),
      CriteriaRow(
        kode: 'C2', label: 'Sparepart',
        rawText: '${labelSparepart(unit.statusSparepart)} (${unit.nilaiC2})',
        sifat: 'Benefit', bobot: BobotKriteria.c2, utility: entry.uC2,
      ),
      CriteriaRow(
        kode: 'C3', label: 'SPK Asuransi',
        rawText: '${labelSpk(unit.statusSpkAsuransi)} (${unit.nilaiC3})',
        sifat: 'Benefit', bobot: BobotKriteria.c3, utility: entry.uC3,
      ),
      CriteriaRow(
        kode: 'C4', label: 'Aging',
        rawText: '${unit.agingHari} hari',
        sifat: 'Benefit', bobot: BobotKriteria.c4, utility: entry.uC4,
      ),
      CriteriaRow(
        kode: 'C5', label: 'Biaya',
        rawText: 'Rp ${formatRupiah(unit.estimasiBiaya)}',
        sifat: 'Cost', bobot: BobotKriteria.c5, utility: entry.uC5,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ring skor besar + status
                  ScoreSummary(value: entry.nilaiUi, siap: siap),
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
                      style: AppText.bodyMuted.copyWith(color: AppColors.ink),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text('Rincian kriteria', style: AppText.heading.copyWith(fontSize: 18)),
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
                    isProcessing: _isProcessing,
                    onPressed: (siap && unit.statusPengerjaan == 'menunggu' && !_isProcessing)
                        ? _terbitkanInstruksi
                        : null,
                    label: unit.statusPengerjaan == 'menunggu'
                        ? 'Terbitkan Instruksi Penugasan Teknisi'
                        : 'Status: ${labelPengerjaan(unit.statusPengerjaan)}',
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
