import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';
import '../../../ui/ui.dart';

Future<bool?> showSparepartUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) {
  return showStatusUpdateSheet(
    context,
    title: 'Ubah Status Sparepart',
    subtitle:
        '${unit.tipeKendaraan} · ${unit.noWO} · saat ini: '
        '${statusOptionTitle(unit.statusSparepart, sparepartStatusOptions)}',
    options: sparepartStatusOptions,
    selected: unit.statusSparepart,
    onSave: (value) =>
        repo.updateUnitFields(unit.id, {'statusSparepart': value}),
  );
}
