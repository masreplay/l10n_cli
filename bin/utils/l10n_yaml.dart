class L10nYaml {
// lib/l10n
  final String? arbDir;
// app_ar.arb
  final String? templateArbFile;
// app_localizations.dart
  final String? outputLocalizationFile;
// untranslated-messages-file.json
  final String? untranslatedMessagesFile;
// false
  final String? nullableGetter;

  L10nYaml({
    required this.arbDir,
    required this.templateArbFile,
    required this.outputLocalizationFile,
    required this.untranslatedMessagesFile,
    required this.nullableGetter,
  });
}
