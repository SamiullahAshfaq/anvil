/// Display-only date formatting for ledgers/receipts. Kept dependency-free and
/// unambiguous (day-month-year), matching the calm mono-figure aesthetic.
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. `22 Jul 2026`.
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// e.g. `22 Jul 2026, 3:07 PM`.
String formatDateTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '${formatDate(d)}, $h:$m $ap';
}

/// Whole days from now until [d], floored at 0 — for the Trash purge countdown.
int daysUntil(DateTime d, {DateTime? now}) {
  final diff = d.difference(now ?? DateTime.now()).inDays;
  return diff < 0 ? 0 : diff;
}
