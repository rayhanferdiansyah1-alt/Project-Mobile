import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';
import '../../../ui/ui.dart';
import 'unit_status_update_sheet.dart';

const _options = [
  StatusOption(
    'disetujui',
    'Disetujui / Cash',
    'Surat jaminan / SPK asuransi disetujui atau cash',
    5,
  ),
  StatusOption(
    'proses_klaim',
    'Proses Klaim',
    'Dokumen masih dalam proses pengajuan klaim / approval',
    3,
  ),
  StatusOption(
    'bermasalah',
    'Bermasalah',
    'Dokumen jaminan belum disetujui / bermasalah',
    1,
  ),
];

Future<bool?> showSpkUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) => showUnitStatusUpdateSheet(
  context,
  unit: unit,
  repo: repo,
  title: 'Ubah Status SPK Asuransi',
  fieldName: 'statusSpkAsuransi',
  currentStatus: unit.statusSpkAsuransi,
  options: _options,
);
