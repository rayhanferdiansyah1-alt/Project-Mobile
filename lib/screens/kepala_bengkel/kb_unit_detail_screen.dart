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
      await _repo.updateUnitFields(widget.unit.id, {
        'statusPengerjaan': 'sedang_dikerjakan',
      });
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Instruksi diterbitkan untuk ${widget.unit.noWO}',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menerbitkan instruksi: $e')),
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
      backgroundColor: AppColors.background,
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
                  ScoreSummary(value: entry.nilaiUi, siap: siap),
                  _KbRecommendation(
                    siap: siap,
                    text: rekomendasiText(
                      peringkat: entry.peringkat,
                      totalUnit: widget.totalUnit,
                      statusSparepart: unit.statusSparepart,
                      statusSpkAsuransi: unit.statusSpkAsuransi,
                      jumlahPanel: unit.jumlahPanel,
                      agingHari: unit.agingHari,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Dasar penilaian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kontribusi setiap kriteria terhadap urutan prioritas.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 15),

                  ...criteria.asMap().entries.map(
                    (e) => CriteriaTile(criteria: e.value, index: e.key),
                  ),

                  const SizedBox(height: 12),
                  WideActionButton(
                    isProcessing: _isProcessing,
                    onPressed:
                        (siap &&
                            unit.statusPengerjaan == 'menunggu' &&
                            !_isProcessing)
                        ? _terbitkanInstruksi
                        : null,
                    label: unit.statusPengerjaan == 'menunggu'
                        ? 'Terbitkan instruksi penugasan'
                        : 'Status: ${labelPengerjaan(unit.statusPengerjaan)}',
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

class _KbRecommendation extends StatelessWidget {
  const _KbRecommendation({required this.siap, required this.text});
  final bool siap;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = siap ? AppColors.success : AppColors.warningText;
    final background = siap ? AppColors.successSoft : AppColors.warningSoft;
    return Container(
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            siap ? Icons.check_circle_outline : Icons.pending_actions_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siap ? 'SIAP MASUK ANTREAN' : 'PERLU TINDAK LANJUT',
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
