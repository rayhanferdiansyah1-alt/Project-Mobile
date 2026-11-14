import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No. WO $noWO sudah dipakai unit lain.')),
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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _FormHeader(primary: primary, isEditMode: _isEditMode)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldBox(
                      label: 'NO. WO / PKB',
                      child: TextFormField(
                        controller: _noWOCtrl,
                        decoration: _plainDecoration('Contoh: 150021-BPM-2026-11-000001'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldBox(
                      label: 'TIPE KENDARAAN',
                      child: TextFormField(
                        controller: _tipeCtrl,
                        decoration: _plainDecoration('Contoh: Mitsubishi Xpander'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldBox(
                      label: 'TANGGAL MASUK',
                      child: InkWell(
                        onTap: _pickTanggal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_tanggalMasuk.day}/${_tanggalMasuk.month}/${_tanggalMasuk.year}',
                              style: const TextStyle(fontSize: 14.5),
                            ),
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade500),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldBox(
                      label: 'JUMLAH PANEL',
                      child: TextFormField(
                        controller: _panelCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _plainDecoration('Isi dalam jumlah panel'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Harus angka bulat > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldBox(
                      label: 'ESTIMASI BIAYA (RP)',
                      child: TextFormField(
                        controller: _biayaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _plainDecoration('Isi dalam rupiah penuh'),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Harus angka > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Status sparepart dan SPK asuransi diisi oleh Partman. Nilai awal unit baru: Back Order dan Proses Klaim.',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
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

InputDecoration _plainDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
    isDense: true,
    border: InputBorder.none,
  );
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.primary, required this.isEditMode});

  final Color primary;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _FormHeaderCurveClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 56, 20, 40),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SERVICE ADVISOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                isEditMode ? 'Edit Unit WIP' : 'Tambah Unit WIP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 24);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}