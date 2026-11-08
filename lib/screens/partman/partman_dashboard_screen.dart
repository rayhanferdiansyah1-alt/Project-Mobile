import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../widgets/app_user_menu.dart';

class PartmanDashboardScreen extends StatelessWidget {
  const PartmanDashboardScreen({super.key});

  static const _sparepartOptions = ['ready', 'order_eo', 'back_order'];
  static const _spkOptions = ['disetujui', 'proses_klaim', 'bermasalah'];

  @override
  Widget build(BuildContext context) {
    final repo = UnitWipRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Logistik & SPK - Partman'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: AppUserMenu()),
        ],
      ),
      body: StreamBuilder<List<UnitWip>>(
        stream: repo.watchUnitWip(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final units = snapshot.data!;
          if (units.isEmpty) {
            return const Center(child: Text('Belum ada unit WIP.'));
          }
          return ListView.builder(
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unit.tipeKendaraan,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('No. WO: ${unit.noWO}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Sparepart: '),
                          DropdownButton<String>(
                            value: unit.statusSparepart,
                            items: _sparepartOptions
                                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              repo.updateUnitFields(unit.id, {'statusSparepart': value});
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('SPK Asuransi: '),
                          DropdownButton<String>(
                            value: unit.statusSpkAsuransi,
                            items: _spkOptions
                                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              repo.updateUnitFields(unit.id, {'statusSpkAsuransi': value});
                            },
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
      ),
    );
  }
}