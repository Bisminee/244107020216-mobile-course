// Fungsi murni untuk formatting. Dipisah dari widget agar bisa diunit-test
// tanpa Flutter sama sekali.
const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// "19 Oktober 2026 07.30"
String formatDateTime(DateTime value) {
  final d = value.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final month = _months[d.month - 1];
  final hour = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '$day $month ${d.year} $hour.$minute';
}

/// "19 Oktober 2026"
String formatDate(DateTime value) {
  final d = value.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  return '$day ${_months[d.month - 1]} ${d.year}';
}

/// "baru saja", "3 menit lalu", "2 hari lalu"
String formatRelative(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(value);

  if (diff.inSeconds < 60) return 'baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 30) return '${diff.inDays} hari lalu';
  return formatDate(value);
}
