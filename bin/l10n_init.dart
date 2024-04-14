import 'dart:io';

/// https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#adding-your-own-localized-messages
Future<void> l10nInit() async {
  /// add dependencies to pubspec.yaml
  await Process.run(
    'flutter',
    ['pub', 'add', 'flutter_localizations', '--sdk=flutter'],
  );
  await Process.run(
    'flutter',
    ['pub', 'add', 'intl:any'],
  );

  /// add flutter: generate: true to pubspec.yaml
  addYamlKeys(
    filename: "pubspec.yaml",
    map: {
      "flutter": {
        "generate": true,
      }
    },
  );
}

/// [map] = {
///   "flutter": {
///     "generate": true,
///   }
/// }
///
/// add on top level only here
/// flutter:
///   generate: true
///
/// don't add it here
/// dependencies:
///  flutter:
///    sdk: flutter

addYamlKeys({
  required String filename,
  required Map<String, dynamic> map,
}) async {
  final file = File(filename);
  final lines = await file.readAsLines();
  final newLines = <String>[];
  var found = false;
  for (var line in lines) {
    if (line.contains('flutter:')) {
      found = true;
    }
    if (found) {
      if (line.contains('flutter:')) {
        newLines.add(line);
        for (var key in map.keys) {
          newLines.add('  $key:');
          for (var subKey in map[key].keys) {
            newLines.add('    $subKey: ${map[key][subKey]}');
          }
        }
      } else {
        newLines.add(line);
      }
    } else {
      newLines.add(line);
    }
  }
  await file.writeAsString(newLines.join('\n'));
}
