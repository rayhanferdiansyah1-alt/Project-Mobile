import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';
import '../../../ui/ui.dart';

Future<bool?> showSpkUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) {
  return showStatusUpdateSheet(
    context,
    title: 'Ubah Status SPK Asuransi',
    subtitle:
        '${unit.tipeKendaraan} · ${unit.noWO} · saat ini: '
        '${statusOptionTitle(unit.statusSpkAsuransi, spkStatusOptions)}',
    options: spkStatusOptions,
    selected: unit.statusSpkAsuransi,
    onSave: (value) =>
        repo.updateUnitFields(unit.id, {'statusSpkAsuransi': value}),
  );
}
