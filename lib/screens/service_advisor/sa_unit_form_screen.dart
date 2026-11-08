import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';

/// Form create/edit unit WIP. Kalau [existingUnit] null -> mode create,
/// kalau diisi -> mode edit (hanya field teknis yang boleh diubah sesuai
/// firestore.rules: noWO, tipeKendaraan, tanggalMasuk, jumlahPanel, estimasiBiaya).
class SaUnitFormScreen extends StatefulWidget {
  const SaUnitFormScreen({super.key, this.existingUnit});

  final UnitWip? existingUnit;

  @override
  State<SaUnitFormScreen> createState() => _SaUnitFormScreenState();
}

class _SaUnitFormScreenState extends State<SaUnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = UnitWipRepository();

  late final TextEditingController _noWOCtrl;
  late final TextEditingController _tipeCtrl;
  late final TextEditingController _panelCtrl;
  late final TextEditingController _biayaCtrl;
  late DateTime _tanggalMasuk;

  bool _isSaving = false;

  bool get _isEditMode => widget.existingUnit != null;

  @override
  void initState() {
    super.initState();
    final u = widget.existingUnit;
    _noWOCtrl = TextEditingController(text: u?.noWO ?? '');
    _tipeCtrl = TextEditingController(text: u?.tipeKendaraan ?? '');
    _panelCtrl = TextEditingController(text: u?.jumlahPanel.toString() ?? '');
    _biayaCtrl = TextEditingController(text: u?.estimasiBiaya.toStringAsFixed(0) ?? '');
    _tanggalMasuk = u?.tanggalMasuk ?? DateTime.now();
  }

  @override
  void dispose() {
    _noWOCtrl.dispose();
    _tipeCtrl.dispose();
    _panelCtrl.dispose();
    _biayaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMasuk,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tanggalMasuk = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final jumlahPanel = int.parse(_panelCtrl.text);
      final estimasiBiaya = double.parse(_biayaCtrl.text);

      if (_isEditMode) {
        await _repo.updateUnitFields(widget.existingUnit!.id, {
          'noWO': _noWOCtrl.text.trim(),
          'tipeKendaraan': _tipeCtrl.text.trim(),
          'tanggalMasuk': Timestamp.fromDate(_tanggalMasuk),
          'jumlahPanel': jumlahPanel,
          'estimasiBiaya': estimasiBiaya,
        });
      } else {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final newUnit = UnitWip(
          id: '',
          noWO: _noWOCtrl.text.trim(),
          tipeKendaraan: _tipeCtrl.text.trim(),
          tanggalMasuk: _tanggalMasuk,
          jumlahPanel: jumlahPanel,
          statusSparepart: 'back_order', // default awal, belum dicek Partman
          statusSpkAsuransi: 'proses_klaim', // default awal, belum disetujui
          estimasiBiaya: estimasiBiaya,
          statusPengerjaan: 'menunggu',
          createdBy: uid,
          updatedAt: DateTime.now(),
        );
        await _repo.createUnit(newUnit);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Unit WIP' : 'Tambah Unit WIP'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _noWOCtrl,
              decoration: const InputDecoration(labelText: 'No. WO / PKB'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tipeCtrl,
              decoration: const InputDecoration(labelText: 'Tipe Kendaraan'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal Masuk'),
              subtitle: Text(
                '${_tanggalMasuk.day}/${_tanggalMasuk.month}/${_tanggalMasuk.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickTanggal,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _panelCtrl,
              decoration: const InputDecoration(labelText: 'Jumlah Panel'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Harus angka bulat > 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _biayaCtrl,
              decoration: const InputDecoration(labelText: 'Estimasi Biaya (Rp)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Harus angka > 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}