import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';

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

      // No. WO adalah identitas unit: tidak boleh ada dua unit dengan No. WO sama.
      final noWO = _noWOCtrl.text.trim();
      final sudahDipakai = await _repo.isNoWOTaken(
        noWO,
        exceptUnitId: widget.existingUnit?.id,
      );
      if (sudahDipakai) {
        if (mounted) {
          showAppSnackbar(
            context,
            'No. WO $noWO sudah dipakai unit lain.',
            kind: SnackKind.error,
          );
        }
        return; // _isSaving dikembalikan oleh blok finally di bawah
      }

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

      if (mounted) Navigator.pop(context, true); // true = berhasil disimpan
    } catch (e) {
      if (mounted) {
        showAppSnackbar(context, 'Gagal menyimpan: $e', kind: SnackKind.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: FormHeader(isEditMode: _isEditMode)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: FieldBox(
                      label: 'No. WO / PKB',
                      child: TextFormField(
                        controller: _noWOCtrl,
                        decoration: plainInputDecoration('Contoh: 150021-BPM-2026-11-000001'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 190),
                      child: FieldBox(
                      label: 'Tipe kendaraan',
                      child: TextFormField(
                        controller: _tipeCtrl,
                        decoration: plainInputDecoration('Contoh: Mitsubishi Xpander'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 260),
                      child: FieldBox(
                      label: 'Tanggal masuk',
                      child: InkWell(
                        onTap: _pickTanggal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_tanggalMasuk.day}/${_tanggalMasuk.month}/${_tanggalMasuk.year}',
                              style: AppText.body.copyWith(fontSize: 14.5),
                            ),
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.muted),
                          ],
                        ),
                      ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 330),
                      child: FieldBox(
                      label: 'Jumlah panel',
                      child: TextFormField(
                        controller: _panelCtrl,
                        keyboardType: TextInputType.number,
                        decoration: plainInputDecoration('Isi dalam jumlah panel'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Harus angka bulat > 0';
                          return null;
                        },
                      ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: FieldBox(
                      label: 'Estimasi biaya (Rp)',
                      child: TextFormField(
                        controller: _biayaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: plainInputDecoration('Isi dalam rupiah penuh'),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Harus angka > 0';
                          return null;
                        },
                      ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Status sparepart dan SPK asuransi diisi oleh Partman. Nilai awal unit baru: Back Order dan Proses Klaim.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 28),
                    CancelSaveButtons(
                      isSaving: _isSaving,
                      onCancel: () => Navigator.pop(context),
                      onSave: _submit,
                      saveFlex: 2,
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
