// sort l10n file

import 'dart:convert';
import 'dart:io';

void main() {
  const filePath = "lib/l10n/app_ar.arb";

  final content = File(filePath);

  final Map<String, dynamic> map = json.decode(content.readAsStringSync());

  final sortedMap = Map.fromEntries(
    map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );

  final sortedJson = const JsonEncoder.withIndent("  ").convert(sortedMap);

  content.writeAsStringSync(sortedJson);
}
