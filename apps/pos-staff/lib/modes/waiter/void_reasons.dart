import '../../l10n/app_localizations.dart';

/// Reason a waiter picks when no other fits; it needs a note.
const voidOther = 'khac';

/// The reasons a branch starts with, until its manager sets its own.
const defaultVoidReasons = ['khach_doi_y', 'het_mon', 'nhap_nham', 'lam_hong'];

/// What the void dialog offers: the branch's reasons ([branch], null when
/// the server did not say), or the defaults; "khac" always comes last.
List<String> voidReasonChoices(List<String>? branch) => [
      ...{...(branch ?? defaultVoidReasons)}.where((code) => code != voidOther),
      voidOther,
    ];

/// The known reasons in the phone's language; a branch's own code reads as
/// its words (`mon_nguoi` → "Mon nguoi").
String voidReasonLabel(AppLocalizations l10n, String code) => switch (code) {
      'khach_doi_y' => l10n.voidReasonChangedMind,
      'het_mon' => l10n.voidReasonSoldOut,
      'nhap_nham' => l10n.voidReasonMistake,
      'lam_hong' => l10n.voidReasonSpoiled,
      voidOther => l10n.voidReasonOther,
      _ => _words(code),
    };

String _words(String code) {
  final text = code.replaceAll('_', ' ').trim();
  return text.isEmpty ? code : '${text[0].toUpperCase()}${text.substring(1)}';
}
