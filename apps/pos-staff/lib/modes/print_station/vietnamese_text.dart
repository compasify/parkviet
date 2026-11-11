// Most receipt printers have no Vietnamese code page. Text mode prints the
// letters without their marks; the `bitmap` code page keeps them by printing
// each line as an image.

const _groups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'A': 'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ',
  'e': 'èéẹẻẽêềếệểễ',
  'E': 'ÈÉẸẺẼÊỀẾỆỂỄ',
  'i': 'ìíịỉĩ',
  'I': 'ÌÍỊỈĨ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'O': 'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ',
  'u': 'ùúụủũưừứựửữ',
  'U': 'ÙÚỤỦŨƯỪỨỰỬỮ',
  'y': 'ỳýỵỷỹ',
  'Y': 'ỲÝỴỶỸ',
  'd': 'đ',
  'D': 'Đ',
};

const _symbols = {
  '₫': 'd',
  '×': 'x',
  '•': '*',
  '·': '.',
  '–': '-',
  '—': '-',
  '‘': "'",
  '’': "'",
  '“': '"',
  '”': '"',
  '…': '...',
  ' ': ' ',
};

final Map<int, String> _fold = {
  for (final entry in _groups.entries)
    for (final rune in entry.value.runes) rune: entry.key,
  for (final entry in _symbols.entries) entry.key.runes.single: entry.value,
};

// Combining marks, in case a string arrives decomposed.
bool _isCombining(int rune) => rune >= 0x0300 && rune <= 0x036f;

/// Printable ASCII only: Vietnamese letters lose their marks, known symbols
/// become their nearest ASCII, anything else becomes `?`.
String foldToAscii(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x20 && rune < 0x7f) {
      out.writeCharCode(rune);
    } else if (_isCombining(rune)) {
      continue;
    } else {
      out.write(_fold[rune] ?? '?');
    }
  }
  return out.toString();
}
