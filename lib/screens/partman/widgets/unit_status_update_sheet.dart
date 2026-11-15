import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';
import '../../../ui/ui.dart';

Future<bool?> showUnitStatusUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
  required String title,
  required String fieldName,
  required String currentStatus,
  required List<StatusOption> options,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UnitStatusUpdateSheet(
      unit: unit,
      repo: repo,
      title: title,
      fieldName: fieldName,
      currentStatus: currentStatus,
      options: options,
    ),
  );
}

class _UnitStatusUpdateSheet extends StatefulWidget {
  const _UnitStatusUpdateSheet({
    required this.unit,
    required this.repo,
    required this.title,
    required this.fieldName,
    required this.currentStatus,
    required this.options,
  });

  final UnitWip unit;
  final UnitWipRepository repo;
  final String title;
  final String fieldName;
  final String currentStatus;
  final List<StatusOption> options;

  @override
  State<_UnitStatusUpdateSheet> createState() => _UnitStatusUpdateSheetState();
}

class _UnitStatusUpdateSheetState extends State<_UnitStatusUpdateSheet> {
  late String _selected = widget.currentStatus;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!widget.options.any((option) => option.value == _selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih salah satu status terlebih dahulu.'),
        ),
      );
      return;
    }
    if (_selected == widget.currentStatus) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.repo.updateUnitFields(widget.unit.id, {
        widget.fieldName: _selected,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = widget.options.firstWhere(
      (option) => option.value == widget.currentStatus,
      orElse: () => StatusOption(
        widget.currentStatus,
        '${widget.currentStatus} (tidak valid)',
        '',
        0,
      ),
    );

    return StatusUpdateSheetView(
      title: widget.title,
      subtitle:
          '${widget.unit.tipeKendaraan} · ${widget.unit.noWO} · saat ini: '
          '${selectedOption.title}',
      options: widget.options,
      selected: _selected,
      onSelect: (value) => setState(() => _selected = value),
      isSaving: _isSaving,
      onCancel: () => Navigator.pop(context, false),
      onSave: _save,
    );
  }
}
