import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../widgets/app_user_menu.dart';

class KbDashboardScreen extends StatefulWidget {
  const KbDashboardScreen({super.key});

  @override
  State<KbDashboardScreen> createState() => _KbDashboardScreenState();
}

class _KbDashboardScreenState extends State<KbDashboardScreen> {
  final _repo = UnitWipRepository();
  String? _processingUnitId;
  bool _isRecomputing = false;

  Future<void> _manualRecompute() async {
    setState(() => _isRecomputing = true);
    try {
      await _repo.recomputeAndSaveRanking();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal recompute: $e')));
      }
    } finally {
      if (mounted) setState(() => _isRecomputing = false);
    }
  }

  Future<void> _terbitkanInstruksi(UnitWip unit) async {
    setState(() => _processingUnitId = unit.id);
    try {
      await _repo.updateUnitFields(unit.id, {'statusPengerjaan': 'sedang_dikerjakan'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instruksi diterbitkan untuk ${unit.noWO}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menerbitkan instruksi: $e')));
      }
    } finally {
      if (mounted) setState(() => _processingUnitId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Prioritas Unit WIP'),
        actions: [
          IconButton(
            icon: _isRecomputing
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _isRecomputing ? null : _manualRecompute,
          ),
          const Padding(padding: EdgeInsets.only(right: 12), child: AppUserMenu()),
        ],
      ),
      body: StreamBuilder<List<UnitWip>>(
        stream: _repo.watchUnitWip(),
        builder: (context, unitSnapshot) {
          if (unitSnapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${unitSnapshot.error}'));
          }
          if (!unitSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final unitById = {for (final u in unitSnapshot.data!) u.id: u};

          return StreamBuilder<List<RankingEntry>>(
            stream: _repo.watchHasilRanking(),
            builder: (context, rankingSnapshot) {
              if (rankingSnapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${rankingSnapshot.error}'));
              }
              if (!rankingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final ranking = rankingSnapshot.data!;
              if (ranking.isEmpty) {
                return const Center(child: Text('Belum ada unit WIP yang bisa diranking.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: ranking.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = ranking[index];
                  final unit = unitById[entry.unitId];
                  if (unit == null) return const SizedBox.shrink();

                  final siapDikerjakan = unit.statusSparepart == 'ready' &&
                      unit.statusSpkAsuransi == 'disetujui';
                  final isProcessing = _processingUnitId == unit.id;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 16, child: Text('${entry.peringkat}')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(unit.tipeKendaraan,
                                        style: Theme.of(context).textTheme.titleMedium),
                                    Text(unit.noWO,
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Text(
                                entry.nilaiUi.toStringAsFixed(4),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: [
                              Chip(label: Text('Panel: ${unit.jumlahPanel}')),
                              Chip(label: Text('Sparepart: ${unit.statusSparepart}')),
                              Chip(label: Text('SPK: ${unit.statusSpkAsuransi}')),
                              Chip(label: Text('Aging: ${unit.agingHari} hari')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                siapDikerjakan ? 'Siap dikerjakan' : 'Menunggu sparepart/SPK',
                                style: TextStyle(
                                  color: siapDikerjakan ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (unit.statusPengerjaan == 'menunggu')
                                ElevatedButton(
                                  onPressed: (siapDikerjakan && !isProcessing)
                                      ? () => _terbitkanInstruksi(unit)
                                      : null,
                                  child: isProcessing
                                      ? const SizedBox(
                                          width: 16, height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Text('Terbitkan Instruksi'),
                                )
                              else
                                Chip(
                                  label: Text(unit.statusPengerjaan),
                                  backgroundColor: Colors.blue.shade50,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}