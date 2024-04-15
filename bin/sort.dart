// sort l10n file

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  // read "arb-dir" from yaml ./l10n.yaml

  final arbDirKey = 'arb-dir';

  final yamlFile = File('l10n.yaml');

  if (!yamlFile.existsSync()) {
    print('l10n.yaml not found');
    return;
  }

  final yamlContent = yamlFile.readAsStringSync();

  final yamlMap = loadYaml(yamlContent);

  if (!yamlMap.containsKey(arbDirKey)) {
    print('arb-dir not found in l10n.yaml');
    return;
  }

  final arbDir = yamlMap[arbDirKey];

  // sort all arb files in arb-dir

  final dir = Directory(arbDir);

  if (!dir.existsSync()) {
    print('arb-dir not found');
    return;
  }

  final arbFiles = dir.listSync().whereType<File>().where((file) {
    final ext = file.path.split('.').last;
    return ext == 'arb';
  });

  for (final file in arbFiles) {
    sortFile(file.path);
  }

  print('Done');
}

Future<void> sortFile(String path) async {
  final content = File(path);

  final Map<String, dynamic> map = json.decode(await content.readAsString());

  final sortedMap = Map.fromEntries(
    map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );

  final sortedJson = const JsonEncoder.withIndent('  ').convert(sortedMap);

  content.writeAsStringSync(sortedJson);
}
