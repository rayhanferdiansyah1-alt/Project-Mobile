import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';
import '../../../ui/ui.dart';
import 'unit_status_update_sheet.dart';

const _options = [
  StatusOption('ready', 'Ready', 'Suku cadang lengkap / tersedia', 5),
  StatusOption('order_eo', 'Order EO', 'Suku cadang dalam proses pemesanan', 3),
  StatusOption('back_order', 'Back Order', 'Suku cadang kosong dari pabrik', 1),
];

Future<bool?> showSparepartUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) => showUnitStatusUpdateSheet(
  context,
  unit: unit,
  repo: repo,
  title: 'Ubah Status Sparepart',
  fieldName: 'statusSparepart',
  currentStatus: unit.statusSparepart,
  options: _options,
);
