import 'package:pubspec_parse/pubspec_parse.dart';

class PubspecL10nConfig {
  // generate flag and intl package
  final bool? generate;
  final bool? intlPackageExists;

  const PubspecL10nConfig({
    required this.generate,
    required this.intlPackageExists,
  });

  bool get shouldGenerate => generate ?? false;
  bool get hasIntlPackage => intlPackageExists ?? false;

  factory PubspecL10nConfig.parse(Pubspec pubspec) {
    final generate = pubspec.flutter!['generate'];
    final intlPackageExists = pubspec.dependencies.containsKey('intl');

    return PubspecL10nConfig(
      generate: generate,
      intlPackageExists: intlPackageExists,
    );
  }
}
