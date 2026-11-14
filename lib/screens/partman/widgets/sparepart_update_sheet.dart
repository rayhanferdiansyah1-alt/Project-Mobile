import 'package:flutter/material.dart';

import '../../../ui/components/status_option.dart';
import '../../../ui/components/status_update_sheet_view.dart';
import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';

const _options = [
  StatusOption('ready', 'Ready', 'Suku cadang lengkap / tersedia', 5),
  StatusOption('order_eo', 'Order EO', 'Suku cadang dalam proses pemesanan', 3),
  StatusOption('back_order', 'Back Order', 'Suku cadang kosong dari pabrik', 1),
];

Future<bool?> showSparepartUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SparepartSheet(unit: unit, repo: repo),
  );
}

class _SparepartSheet extends StatefulWidget {
  const _SparepartSheet({required this.unit, required this.repo});
  final UnitWip unit;
  final UnitWipRepository repo;

  @override
  State<_SparepartSheet> createState() => _SparepartSheetState();
}

class _SparepartSheetState extends State<_SparepartSheet> {
  late String _selected = widget.unit.statusSparepart;
  bool _isSaving = false;

  Future<void> _simpan() async {
    // Nilai lama di database bisa tidak valid (mis. hasil input manual).
    if (!_options.any((o) => o.value == _selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih salah satu status terlebih dahulu.')),
      );
      return;
    }
    // Tidak ada perubahan -> tutup saja, jangan tulis ke Firestore.
    if (_selected == widget.unit.statusSparepart) {
      Navigator.pop(context, false);
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.repo.updateUnitFields(widget.unit.id, {'statusSparepart': _selected});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusUpdateSheetView(
      title: 'Ubah Status Sparepart',
      subtitle: '${widget.unit.tipeKendaraan} · ${widget.unit.noWO} · saat ini: '
          '${_labelOf(widget.unit.statusSparepart)}',
      options: _options,
      selected: _selected,
      onSelect: (v) => setState(() => _selected = v),
      isSaving: _isSaving,
      onCancel: () => Navigator.pop(context, false),
      onSave: _simpan,
    );
  }

  String _labelOf(String v) => _options
      .firstWhere(
        (o) => o.value == v,
        orElse: () => StatusOption(v, '$v (tidak valid)', '', 0),
      )
      .title;
}
