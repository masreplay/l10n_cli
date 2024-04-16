// Adding your own localized messages
/// #
/// After adding the flutter_localizations package, you can configure localization. To add localized text to your application, complete the following instructions:

/// Add the intl package as a dependency, pulling in the version pinned by flutter_localizations:

/// $ flutter pub add intl:any
/// content_copy
/// Open the pubspec.yaml file and enable the generate flag. This flag is found in the flutter section in the pubspec file.

/// # The following section is specific to Flutter.
/// flutter:
///   generate: true # Add this line
/// content_copy
/// Add a new yaml file to the root directory of the Flutter project. Name this file l10n.yaml and include following content:

/// arb-dir: lib/l10n
/// template-arb-file: app_en.arb
/// output-localization-file: app_localizations.dart
/// content_copy
/// This file configures the localization tool. In this example, you've done the following:

/// Put the App Resource Bundle (.arb) input files in ${FLUTTER_PROJECT}/lib/l10n. The .arb provide localization resources for your app.
/// Set the English template as app_en.arb.
/// Told Flutter to generate localizations in the app_localizations.dart file.
/// In ${FLUTTER_PROJECT}/lib/l10n, add the app_en.arb template file. For example:

/// {
///   "helloWorld": "Hello World!",
///   "@helloWorld": {
///     "description": "The conventional newborn programmer greeting"
///   }
/// }
/// content_copy
/// Add another bundle file called app_es.arb in the same directory. In this file, add the Spanish translation of the same message.

/// {
///     "helloWorld": "¡Hola Mundo!"
/// }
/// content_copy
/// Now, run flutter pub get or flutter run and codegen takes place automatically. You should find generated files in ${FLUTTER_PROJECT}/.dart_tool/flutter_gen/gen_l10n. Alternatively, you can also run flutter gen-l10n to generate the same files without running the app.

/// Add the import statement on app_localizations.dart and AppLocalizations.delegate in your call to the constructor for MaterialApp:

/// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
/// content_copy
/// return const MaterialApp(
///   title: 'Localizations Sample App',
///   localizationsDelegates: [
///     AppLocalizations.delegate, // Add this line
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///     GlobalCupertinoLocalizations.delegate,
///   ],
///   supportedLocales: [
///     Locale('en'), // English
///     Locale('es'), // Spanish
///   ],
///   home: MyHomePage(),
/// );
/// content_copy
/// The AppLocalizations class also provides auto-generated localizationsDelegates and supportedLocales lists. You can use these instead of providing them manually.

/// const MaterialApp(
///   title: 'Localizations Sample App',
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
/// );
/// content_copy
/// Once the Material app has started, you can use AppLocalizations anywhere in your app:

/// appBar: AppBar(
///   // The [AppBar] title text should update its message
///   // according to the system locale of the target platform.
///   // Switching between English and Spanish locales should
///   // cause this text to update.
///   title: Text(AppLocalizations.of(context)!.helloWorld),
/// ),
library;
