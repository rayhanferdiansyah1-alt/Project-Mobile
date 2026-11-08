import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import 'sa_unit_form_screen.dart';

class SaDashboardScreen extends StatelessWidget {
  const SaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = UnitWipRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Unit WIP - Service Advisor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaUnitFormScreen()),
        ),
        child: const Icon(Icons.add),
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
            return const Center(child: Text('Belum ada unit WIP. Tekan + untuk menambah.'));
          }
          return ListView.builder(
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(unit.tipeKendaraan),
                  subtitle: Text(
                    'No. WO: ${unit.noWO}\n'
                    'Panel: ${unit.jumlahPanel} | Biaya: Rp ${unit.estimasiBiaya.toStringAsFixed(0)}\n'
                    'Sparepart: ${unit.statusSparepart} | SPK: ${unit.statusSpkAsuransi}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SaUnitFormScreen(existingUnit: unit),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, repo, unit),
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

  void _confirmDelete(BuildContext context, UnitWipRepository repo, UnitWip unit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Unit'),
        content: Text('Hapus data unit ${unit.noWO}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.deleteUnit(unit.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}