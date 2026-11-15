import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';

const _options = [
  StatusOption('disetujui', 'Disetujui / Cash', 'Surat jaminan / SPK asuransi disetujui atau cash', 5),
  StatusOption('proses_klaim', 'Proses Klaim', 'Dokumen masih dalam proses pengajuan klaim / approval', 3),
  StatusOption('bermasalah', 'Bermasalah', 'Dokumen jaminan belum disetujui / bermasalah', 1),
];

Future<bool?> showSpkUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.ink.withValues(alpha: 0.3),
    builder: (_) => _SpkSheet(unit: unit, repo: repo),
  );
}

class _SpkSheet extends StatefulWidget {
  const _SpkSheet({required this.unit, required this.repo});
  final UnitWip unit;
  final UnitWipRepository repo;

  @override
  State<_SpkSheet> createState() => _SpkSheetState();
}

class _SpkSheetState extends State<_SpkSheet> {
  late String _selected = widget.unit.statusSpkAsuransi;
  bool _isSaving = false;

  Future<void> _simpan() async {
    if (!_options.any((o) => o.value == _selected)) {
      showAppSnackbar(
        context,
        'Pilih salah satu status terlebih dahulu.',
        kind: SnackKind.info,
      );
      return;
    }

    if (_selected == widget.unit.statusSpkAsuransi) {
      Navigator.pop(context, false);
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.repo.updateUnitFields(widget.unit.id, {'statusSpkAsuransi': _selected});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showAppSnackbar(context, 'Gagal menyimpan: $e', kind: SnackKind.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusUpdateSheetView(
      title: 'Ubah Status SPK Asuransi',
      subtitle: '${widget.unit.tipeKendaraan} · ${widget.unit.noWO} · saat ini: '
          '${_labelOf(widget.unit.statusSpkAsuransi)}',
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
