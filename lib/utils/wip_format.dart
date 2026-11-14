/// "0.8666" -> "0,8666"
String idDecimal(double value, {int decimals = 4}) {
  return value.toStringAsFixed(decimals).replaceAll('.', ',');
}

/// 4200000 -> "4.200.000"
String formatRupiah(num value) {
  final s = value.toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    buffer.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

String labelSparepart(String status) {
  switch (status) {
    case 'ready':
      return 'Ready';
    case 'order_eo':
      return 'Order EO';
    case 'back_order':
      return 'Back Order';
    default:
      return status;
  }
}

String labelSpk(String status) {
  switch (status) {
    case 'disetujui':
      return 'Disetujui';
    case 'proses_klaim':
      return 'Proses Klaim';
    case 'bermasalah':
      return 'Bermasalah';
    default:
      return status;
  }
}

String labelPengerjaan(String status) {
  switch (status) {
    case 'menunggu':
      return 'Menunggu';
    case 'sedang_dikerjakan':
      return 'Sedang Dikerjakan';
    case 'selesai':
      return 'Selesai';
    default:
      return status;
  }
}

bool isSiapDikerjakan({required String statusSparepart, required String statusSpkAsuransi}) {
  return statusSparepart == 'ready' && statusSpkAsuransi == 'disetujui';
}

/// "Prioritas Utama (P1)" | "Prioritas ke-N" | "Prioritas Terakhir"
String prioritasLabel(int peringkat, int totalUnit) {
  if (peringkat == 1) return 'Prioritas Utama (P1)';
  if (peringkat == totalUnit) return 'Prioritas Terakhir';
  return 'Prioritas ke-$peringkat';
}

String rekomendasiText({
  required int peringkat,
  required int totalUnit,
  required String statusSparepart,
  required String statusSpkAsuransi,
  required int jumlahPanel,
  required int agingHari,
  String statusPengerjaan = 'menunggu',
}) {
  final label = prioritasLabel(peringkat, totalUnit);

  if (statusPengerjaan == 'sedang_dikerjakan') {
    return '$label: sedang dikerjakan (aging $agingHari hari, $jumlahPanel panel).';
  }
  if (statusPengerjaan == 'selesai') {
    return '$label: pengerjaan selesai.';
  }

  if (isSiapDikerjakan(statusSparepart: statusSparepart, statusSpkAsuransi: statusSpkAsuransi)) {
    return '$label: kerjakan segera (aging $agingHari hari, $jumlahPanel panel, '
        'part & SPK ready).';
  }
  if (statusSparepart != 'ready') {
    return '$label: tunggu kedatangan sparepart (status ${labelSparepart(statusSparepart)}).';
  }
  return '$label: menunggu persetujuan SPK Asuransi '
      '(status ${labelSpk(statusSpkAsuransi)}).';
}