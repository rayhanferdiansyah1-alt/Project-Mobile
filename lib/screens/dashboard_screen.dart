import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../logic/smart_calculator.dart';
import '../services/unit_wip_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repository = UnitWipRepository();
  late Future<List<HasilSmart>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAndCalculate();
  }

  Future<List<HasilSmart>> _loadAndCalculate() async {
    final units = await _repository.getAllUnits();
    return hitungSmart(units);
  }

  void _refresh() {
    setState(() {
      _future = _loadAndCalculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Prioritas WIP'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<List<HasilSmart>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat data:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final hasilList = snapshot.data ?? [];
          if (hasilList.isEmpty) {
            return const Center(child: Text('Belum ada data unit WIP.'));
          }
          return ListView.builder(
            itemCount: hasilList.length,
            itemBuilder: (context, index) {
              final hasil = hasilList[index];
              final peringkat = index + 1;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text('$peringkat')),
                  title: Text(hasil.unit.tipeKendaraan),
                  subtitle: Text(
                    'No. WO: ${hasil.unit.noWO}\n'
                    'Panel: ${hasil.unit.jumlahPanel} | '
                    'Aging: ${hasil.unit.agingHari} hari',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    hasil.ui.toStringAsFixed(4),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
