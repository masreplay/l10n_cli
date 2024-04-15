// ignore_for_file: depend_on_referenced_packages

import "dart:convert";
import "dart:io";

import "package:glob/glob.dart";
import "package:glob/list_local_fs.dart";

void main() {
  final root = Directory.current.path;
  final rootPosix = root.replaceAll("\\", "/");

  final stringKeys = getStringKeys(rootPosix);
  final dartFiles = getDartFiles(rootPosix);

  final unusedStringKeys = findUnusedStringKeys(stringKeys, dartFiles);
  writeUnusedFile(unusedStringKeys);

  // delete directly if --delete flag is passed
  if (Platform.environment.containsKey("delete")) {
    for (final file in dartFiles) {
      final content = File(file).readAsStringSync();
      for (final stringKey in unusedStringKeys) {
        if (content.contains(".$stringKey")) {
          final newContent = content.replaceAll(".$stringKey", "");
          File(file).writeAsStringSync(newContent);
        }
      }
    }
  }
}

Set<String> getStringKeys(String path) {
  final arbFilesGlob = Glob("$path/**.arb");

  final arbFiles = <String>[];
  for (var entity in arbFilesGlob.listSync(followLinks: false)) {
    arbFiles.add(entity.path);
  }

  final stringKeys = <String>{};
  for (final file in arbFiles) {
    final content = File(file).readAsStringSync();
    final map = jsonDecode(content) as Map<String, dynamic>;
    for (final entry in map.entries) {
      if (!entry.key.startsWith("@")) {
        stringKeys.add(entry.key);
      }
    }
  }

  return stringKeys;
}

List<String> getDartFiles(String path) {
  final dartFilesGlob = Glob("$path/lib/**.dart");
  final dartFilesExcludeGlob = Glob("$path/lib/generated/**.dart");

  final dartFilesExclude = <String>[];
  for (var entity in dartFilesExcludeGlob.listSync(followLinks: false)) {
    dartFilesExclude.add(entity.path);
  }

  final dartFiles = <String>[];
  for (var entity in dartFilesGlob.listSync(followLinks: false)) {
    if (!dartFilesExclude.contains(entity.path)) {
      dartFiles.add(entity.path);
    }
  }

  return dartFiles;
}

Set<String> findUnusedStringKeys(Set<String> stringKeys, List<String> files) {
  final unusedStringKeys = stringKeys.toSet();

  for (final file in files) {
    final content = File(file).readAsStringSync();
    for (final stringKey in stringKeys) {
      if (content.contains(".$stringKey")) {
        unusedStringKeys.remove(stringKey);
      }
    }
  }

  return unusedStringKeys;
}

/// unused-messages-file.json
/// {
///   [
///    "stringKey1",
///    "stringKey2",
///   ]
/// }
///
Future<void> writeUnusedFile(Set<String> unusedStringKeys) async {
  final file = File("unused-messages-file.json");
  final sink = file.openWrite();
  sink.write(JsonEncoder.withIndent("  ").convert(unusedStringKeys.toList()));
  await sink.flush();
  await sink.close();
}
