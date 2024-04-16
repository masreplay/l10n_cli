import 'dart:io';

import 'package:logger/logger.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'l10n_yaml/l10n_options.dart';
import 'l10n_yaml/l10n_paths.dart';
import 'l10n_yaml/pubspec_l10n_config.dart';
import 'l10n_yaml/utils/configure_l10n.dart';
import 'l10n_yaml/utils/configure_l10n_options.dart';

final logger = Logger();

Future<L10nConfig> checkL10nConfig() async {
  final pubspecFile = File(pubspecYamlPath);

  if (!await pubspecFile.exists()) {
    throw Exception("pubspec.yaml file not found");
  }

  final pubspec = Pubspec.parse(await pubspecFile.readAsString());

  return L10nConfig.parse(pubspec);
}

Future<void> initL10nCommand() async {
  final config = await checkL10nConfig();
  print(config);
  if (config.isConfigured) {
    print("L10n configuration is correctly");
  } else {
    configureL10n(config);
  }

  final options = LocalizationOptions.parseFromYAML(
    file: File(l10nYamlPath),
    logger: logger,
    defaultArbDir: defaultArbDir,
  );

  configureL10nOptions(options);
}

void main(List<String> args) {
  initL10nCommand();
}
