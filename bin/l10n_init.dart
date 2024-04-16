import 'dart:io';

import 'package:logger/logger.dart';

import 'tools/parse.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

final logger = Logger();

const String defaultL10nYamlPath = 'l10n.yaml';
const String defaultArbPath = 'lib/l10n';

Future<bool> isL10nConfigured() async {
  final pubspecFile = File('pubspec.yaml');

  if (!await pubspecFile.exists()) {
    print("pubspec.yaml file not found");
    return false;
  }

  final pubspec = Pubspec.parse(await pubspecFile.readAsString());

  if (pubspec.flutter == null) {
    print("pubspec: flutter section not found in pubspec.yaml");
    return false;
  }

  final pubspecL10nConfig = parsePubspecL10nConfig(pubspec);

  if (!pubspecL10nConfig.shouldGenerate) {
    print("l10n: generate flag not found in pubspec.yaml");
    return false;
  }

  if (!pubspecL10nConfig.hasIntlPackage) {
    print("l10n: intl package not found in pubspec.yaml");
    return false;
  }

  final l10nYamlFile = File(defaultL10nYamlPath);

  if (!await l10nYamlFile.exists()) {
    print("l10n.yaml file not found");
    return false;
  }

  return true;
}

Future<void> initL10nCommand() async {
  final configured = await isL10nConfigured();

  if (configured) {
    print("l10n: already configured");

    return;
  }

  final l10nYamlFile = File('l10n.yaml');

  if (!await l10nYamlFile.exists()) {
    print("l10n.yaml file not found");
    return;
  }

  final options = parseLocalizationsOptionsFromYAML(
    file: l10nYamlFile,
    logger: logger,
    defaultArbDir: defaultArbPath,
  );

  print(options);
}

void main(List<String> args) {
  initL10nCommand();
}

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
}

PubspecL10nConfig parsePubspecL10nConfig(Pubspec pubspec) {
  final generate = pubspec.flutter!['generate'];
  final intlPackageExists = pubspec.dependencies.containsKey('intl');

  return PubspecL10nConfig(
    generate: generate,
    intlPackageExists: intlPackageExists,
  );
}
