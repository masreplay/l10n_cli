import 'dart:io';

import 'package:logger/logger.dart';
import 'package:yaml/yaml.dart';

class LocalizationOptions {
  LocalizationOptions({
    required this.arbDir,
    this.outputDir,
    String? templateArbFile,
    String? outputLocalizationFile,
    this.untranslatedMessagesFile,
    String? outputClass,
    this.preferredSupportedLocales,
    this.header,
    this.headerFile,
    bool? useDeferredLoading,
    this.genInputsAndOutputsList,
    bool? syntheticPackage,
    this.projectDir,
    bool? requiredResourceAttributes,
    bool? nullableGetter,
    bool? format,
    bool? useEscaping,
    bool? suppressWarnings,
    bool? relaxSyntax,
    bool? useNamedParameters,
  })  : templateArbFile = templateArbFile ?? 'app_en.arb',
        outputLocalizationFile =
            outputLocalizationFile ?? 'app_localizations.dart',
        outputClass = outputClass ?? 'AppLocalizations',
        useDeferredLoading = useDeferredLoading ?? false,
        syntheticPackage = syntheticPackage ?? true,
        requiredResourceAttributes = requiredResourceAttributes ?? false,
        nullableGetter = nullableGetter ?? true,
        format = format ?? false,
        useEscaping = useEscaping ?? false,
        suppressWarnings = suppressWarnings ?? false,
        relaxSyntax = relaxSyntax ?? false,
        useNamedParameters = useNamedParameters ?? false;

  /// The `--arb-dir` argument.
  ///
  /// The directory where all input localization files should reside.
  final String arbDir;

  /// The `--output-dir` argument.
  ///
  /// The directory where all output localization files should be generated.
  final String? outputDir;

  /// The `--template-arb-file` argument.
  ///
  /// This path is relative to [arbDirectory].
  final String templateArbFile;

  /// The `--output-localization-file` argument.
  ///
  /// This path is relative to [arbDir].
  final String outputLocalizationFile;

  /// The `--untranslated-messages-file` argument.
  ///
  /// This path is relative to [arbDir].
  final String? untranslatedMessagesFile;

  /// The `--output-class` argument.
  final String outputClass;

  /// The `--preferred-supported-locales` argument.
  final List<String>? preferredSupportedLocales;

  /// The `--header` argument.
  ///
  /// The header to prepend to the generated Dart localizations.
  final String? header;

  /// The `--header-file` argument.
  ///
  /// A file containing the header to prepend to the generated
  /// Dart localizations.
  final String? headerFile;

  /// The `--use-deferred-loading` argument.
  ///
  /// Whether to generate the Dart localization file with locales imported
  /// as deferred.
  final bool useDeferredLoading;

  /// The `--gen-inputs-and-outputs-list` argument.
  ///
  /// This path is relative to [arbDir].
  final String? genInputsAndOutputsList;

  /// The `--synthetic-package` argument.
  ///
  /// Whether to generate the Dart localization files in a synthetic package
  /// or in a custom directory.
  final bool syntheticPackage;

  /// The `--project-dir` argument.
  ///
  /// This path is relative to [arbDir].
  final String? projectDir;

  /// The `required-resource-attributes` argument.
  ///
  /// Whether to require all resource ids to contain a corresponding
  /// resource attribute.
  final bool requiredResourceAttributes;

  /// The `nullable-getter` argument.
  ///
  /// Whether or not the localizations class getter is nullable.
  final bool nullableGetter;

  /// The `format` argument.
  ///
  /// Whether or not to format the generated files.
  final bool format;

  /// The `use-escaping` argument.
  ///
  /// Whether or not the ICU escaping syntax is used.
  final bool useEscaping;

  /// The `suppress-warnings` argument.
  ///
  /// Whether or not to suppress warnings.
  final bool suppressWarnings;

  /// The `relax-syntax` argument.
  ///
  /// Whether or not to relax the syntax. When specified, the syntax will be
  /// relaxed so that the special character "{" is treated as a string if it is
  /// not followed by a valid placeholder and "}" is treated as a string if it
  /// does not close any previous "{" that is treated as a special character.
  /// This was added in for backward compatibility and is not recommended
  /// as it may mask errors.
  final bool relaxSyntax;

  /// The `use-named-parameters` argument.
  ///
  /// Whether or not to use named parameters for the generated localization
  /// methods.
  ///
  /// Defaults to `false`.
  final bool useNamedParameters;
}

/// Parse the localizations configuration options from [file].
///
/// Throws [Exception] if any of the contents are invalid. Returns a
/// [LocalizationOptions] with all fields as `null` if the config file exists
/// but is empty.
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
    logger.e(err.message);
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
