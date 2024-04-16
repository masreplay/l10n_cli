// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:logger/logger.dart';
import 'package:yaml/yaml.dart';

import 'l10n_options.dart';

LocalizationOptions parseLocalizationsOptionsFromYAML({
  required File file,
  required Logger logger,
  required String defaultArbDir,
}) {
  final String contents = file.readAsStringSync();
  if (contents.trim().isEmpty) {
    return LocalizationOptions(arbDir: defaultArbDir);
  }
  final YamlNode yamlNode;
  try {
    yamlNode = loadYamlNode(file.readAsStringSync());
  } on YamlException catch (err) {
    logger.e('Error detected in ${file.path}: $err');
    throw Exception();
  }
  if (yamlNode is! YamlMap) {
    logger.e('Expected ${file.path} to contain a map, instead was $yamlNode');
    throw Exception();
  }
  return LocalizationOptions(
    arbDir: _tryReadUri(yamlNode, 'arb-dir', logger)?.path ?? defaultArbDir,
    outputDir: _tryReadUri(yamlNode, 'output-dir', logger)?.path,
    templateArbFile: _tryReadUri(yamlNode, 'template-arb-file', logger)?.path,
    outputLocalizationFile:
        _tryReadUri(yamlNode, 'output-localization-file', logger)?.path,
    untranslatedMessagesFile:
        _tryReadUri(yamlNode, 'untranslated-messages-file', logger)?.path,
    outputClass: _tryReadString(yamlNode, 'output-class', logger),
    header: _tryReadString(yamlNode, 'header', logger),
    headerFile: _tryReadUri(yamlNode, 'header-file', logger)?.path,
    useDeferredLoading: _tryReadBool(yamlNode, 'use-deferred-loading', logger),
    preferredSupportedLocales:
        _tryReadStringList(yamlNode, 'preferred-supported-locales', logger),
    syntheticPackage: _tryReadBool(yamlNode, 'synthetic-package', logger),
    requiredResourceAttributes:
        _tryReadBool(yamlNode, 'required-resource-attributes', logger),
    nullableGetter: _tryReadBool(yamlNode, 'nullable-getter', logger),
    format: _tryReadBool(yamlNode, 'format', logger),
    useEscaping: _tryReadBool(yamlNode, 'use-escaping', logger),
    suppressWarnings: _tryReadBool(yamlNode, 'suppress-warnings', logger),
    relaxSyntax: _tryReadBool(yamlNode, 'relax-syntax', logger),
    useNamedParameters: _tryReadBool(yamlNode, 'use-named-parameters', logger),
  );
}

// Try to read a `bool` value or null from `yamlMap`, otherwise throw.
bool? _tryReadBool(YamlMap yamlMap, String key, Logger logger) {
  final Object? value = yamlMap[key];
  if (value == null) {
    return null;
  }
  if (value is! bool) {
    logger.e('Expected "$key" to have a bool value, instead was "$value"');
    throw Exception();
  }
  return value;
}

// Try to read a `String` value or null from `yamlMap`, otherwise throw.
String? _tryReadString(YamlMap yamlMap, String key, Logger logger) {
  final Object? value = yamlMap[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    logger.e('Expected "$key" to have a String value, instead was "$value"');
    throw Exception();
  }
  return value;
}

List<String>? _tryReadStringList(YamlMap yamlMap, String key, Logger logger) {
  final Object? value = yamlMap[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return <String>[value];
  }
  if (value is Iterable) {
    return value.map((dynamic e) => e.toString()).toList();
  }
  logger.e('"$value" must be String or List.');
  throw Exception();
}

// Try to read a valid `Uri` or null from `yamlMap`, otherwise throw.
Uri? _tryReadUri(YamlMap yamlMap, String key, Logger logger) {
  final String? value = _tryReadString(yamlMap, key, logger);
  if (value == null) {
    return null;
  }
  final Uri? uri = Uri.tryParse(value);
  if (uri == null) {
    logger.e('"$value" must be a relative file URI');
  }
  return uri;
}
