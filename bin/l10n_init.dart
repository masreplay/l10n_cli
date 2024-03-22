import 'dart:io';

Future<void> l10nInit() async {
  // run commands
  await Process.run(
    'flutter',
    ['pub', 'add', 'flutter_localizations', '--sdk=flutter'],
  );
  await Process.run(
    'flutter',
    ['pub', 'add', 'intl:any'],
  );
}
