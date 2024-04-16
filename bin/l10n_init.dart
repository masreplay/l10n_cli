import 'dart:io';

import 'package:logger/logger.dart';

import 'l10n_yaml/l10n_paths.dart';
import 'l10n_yaml/localization_utils.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'l10n_yaml/pubspec_l10n_config.dart';

final logger = Logger();

Future<bool> isL10nConfigured() async {
  final pubspecFile = File(pubspecYamlPath);

  if (!await pubspecFile.exists()) {
    print("pubspec.yaml file not found");
    return false;
  }

  final pubspec = Pubspec.parse(await pubspecFile.readAsString());

  if (pubspec.flutter == null) {
    print("pubspec: flutter section not found in pubspec.yaml");
    return false;
  }

  final pubspecL10nConfig = PubspecL10nConfig.parse(pubspec);

  if (!pubspecL10nConfig.shouldGenerate) {
    print("l10n: generate flag not found in pubspec.yaml");
    return false;
  }

  if (!pubspecL10nConfig.hasIntlPackage) {
    print("l10n: intl package not found in pubspec.yaml");
    return false;
  }

  final l10nYamlFile = File(l10nYamlPath);

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

  final l10nYamlFile = File(l10nYamlPath);

  final l10nOptions = parseLocalizationsOptionsFromYAML(
    file: l10nYamlFile,
    logger: logger,
    defaultArbDir: defaultArbPath,
  );

  print(l10nOptions);
}

void main(List<String> args) {
  initL10nCommand();
}
