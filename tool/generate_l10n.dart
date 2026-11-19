// Generates the Localizely-compatible `S` API and message lookups from the
// ARB sources in `lib/l10n`.
//
// Usage (from the project root):
//   dart run tool/generate_l10n.dart
//
// The output matches the conventions produced by the Flutter Intl IDE plugin
// (`S` class in `lib/generated/l10n.dart` plus `messages_*.dart` lookups), so
// existing call sites keep working without adding new dependencies.
import 'dart:convert';
import 'dart:io';

const _locales = <String>['en', 'ar'];
const _l10nDir = 'lib/l10n';
const _outputDir = 'lib/generated';

void main() {
  final messages = <String, Map<String, String>>{};
  for (final locale in _locales) {
    messages[locale] = _readArb('$_l10nDir/intl_$locale.arb');
  }

  final base = messages['en']!;
  final keys = base.keys.toList(growable: false);

  for (final locale in _locales) {
    final missing = keys.where((key) => !messages[locale]!.containsKey(key));
    if (missing.isNotEmpty) {
      stderr.writeln(
        'Missing $locale translations for: ${missing.join(', ')}',
      );
      exitCode = 1;
      return;
    }
    final extra =
        messages[locale]!.keys.where((key) => !base.containsKey(key)).toList();
    if (extra.isNotEmpty) {
      stderr.writeln(
        'Extra $locale translations without an English source: '
        '${extra.join(', ')}',
      );
      exitCode = 1;
      return;
    }
  }

  _writeFile('$_outputDir/l10n.dart', _buildL10n(base, keys));
  for (final locale in _locales) {
    _writeFile(
      '$_outputDir/intl/messages_$locale.dart',
      _buildMessageLookup(locale, messages[locale]!, keys),
    );
  }
  _writeFile('$_outputDir/intl/messages_all.dart', _buildMessagesAll());

  stdout.writeln(
    'Generated ${keys.length} messages for ${_locales.join(', ')}.',
  );
}

Map<String, String> _readArb(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('ARB file not found: $path');
    exit(1);
  }
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final result = <String, String>{};
  for (final entry in decoded.entries) {
    if (entry.key.startsWith('@')) continue;
    final value = entry.value;
    if (value is! String || value.trim().isEmpty) {
      stderr.writeln('Invalid or empty value for "${entry.key}" in $path');
      exit(1);
    }
    result[entry.key] = value;
  }
  return result;
}

void _writeFile(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}

String _escapeSingleQuoted(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$')
    .replaceAll('\r', '')
    .replaceAll('\n', r'\n');

String _escapeDoubleQuoted(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('"', r'\"')
    .replaceAll(r'$', r'\$')
    .replaceAll('\r', '')
    .replaceAll('\n', r'\n');

String _singleLine(String value) => value.replaceAll('\n', ' ');

String _buildL10n(Map<String, String> base, List<String> keys) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:intl/intl.dart';")
    ..writeln()
    ..writeln("import 'intl/messages_all.dart';")
    ..writeln()
    ..writeln('// **************************************************************************')
    ..writeln('// Generator: Flutter Intl IDE plugin')
    ..writeln('// Made by Localizely')
    ..writeln('// **************************************************************************')
    ..writeln()
    ..writeln('// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars')
    ..writeln('// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each')
    ..writeln('// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes')
    ..writeln()
    ..writeln('class S {')
    ..writeln('  S();')
    ..writeln()
    ..writeln('  static S? _current;')
    ..writeln()
    ..writeln('  static S get current {')
    ..writeln('    assert(')
    ..writeln('      _current != null,')
    ..writeln("      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',")
    ..writeln('    );')
    ..writeln('    return _current!;')
    ..writeln('  }')
    ..writeln()
    ..writeln('  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();')
    ..writeln()
    ..writeln('  static Future<S> load(Locale locale) {')
    ..writeln('    final name = (locale.countryCode?.isEmpty ?? false)')
    ..writeln('        ? locale.languageCode')
    ..writeln('        : locale.toString();')
    ..writeln('    final localeName = Intl.canonicalizedLocale(name);')
    ..writeln('    return initializeMessages(localeName).then((_) {')
    ..writeln('      Intl.defaultLocale = localeName;')
    ..writeln('      final instance = S();')
    ..writeln('      S._current = instance;')
    ..writeln()
    ..writeln('      return instance;')
    ..writeln('    });')
    ..writeln('  }')
    ..writeln()
    ..writeln('  static S of(BuildContext context) {')
    ..writeln('    final instance = S.maybeOf(context);')
    ..writeln('    assert(')
    ..writeln('      instance != null,')
    ..writeln("      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',")
    ..writeln('    );')
    ..writeln('    return instance!;')
    ..writeln('  }')
    ..writeln()
    ..writeln('  static S? maybeOf(BuildContext context) {')
    ..writeln('    return Localizations.of<S>(context, S);')
    ..writeln('  }');

  for (final key in keys) {
    final value = base[key]!;
    buffer
      ..writeln()
      ..writeln('  /// `${_singleLine(value)}`')
      ..writeln('  String get $key {')
      ..writeln(
        "    return Intl.message('${_escapeSingleQuoted(value)}', "
        "name: '$key', desc: '', args: []);",
      )
      ..writeln('  }');
  }

  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('class AppLocalizationDelegate extends LocalizationsDelegate<S> {')
    ..writeln('  const AppLocalizationDelegate();')
    ..writeln()
    ..writeln('  List<Locale> get supportedLocales {')
    ..writeln('    return const <Locale>[');

  for (final locale in _locales) {
    buffer.writeln("      Locale.fromSubtags(languageCode: '$locale'),");
  }

  buffer
    ..writeln('    ];')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  bool isSupported(Locale locale) => _isSupported(locale);')
    ..writeln('  @override')
    ..writeln('  Future<S> load(Locale locale) => S.load(locale);')
    ..writeln('  @override')
    ..writeln('  bool shouldReload(AppLocalizationDelegate old) => false;')
    ..writeln()
    ..writeln('  bool _isSupported(Locale locale) {')
    ..writeln('    for (var supportedLocale in supportedLocales) {')
    ..writeln('      if (supportedLocale.languageCode == locale.languageCode) {')
    ..writeln('        return true;')
    ..writeln('      }')
    ..writeln('    }')
    ..writeln('    return false;')
    ..writeln('  }')
    ..writeln('}');

  return buffer.toString();
}

String _buildMessageLookup(
  String locale,
  Map<String, String> messages,
  List<String> keys,
) {
  final buffer = StringBuffer()
    ..writeln('// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart')
    ..writeln('// This is a library that provides messages for a $locale locale. All the')
    ..writeln('// messages from the main program should be duplicated here with the same')
    ..writeln('// function name.')
    ..writeln()
    ..writeln('// Ignore issues from commonly used lints in this file.')
    ..writeln('// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new')
    ..writeln('// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering')
    ..writeln('// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases')
    ..writeln('// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes')
    ..writeln('// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes')
    ..writeln()
    ..writeln("import 'package:intl/intl.dart';")
    ..writeln("import 'package:intl/message_lookup_by_library.dart';")
    ..writeln()
    ..writeln('final messages = new MessageLookup();')
    ..writeln()
    ..writeln('typedef String MessageIfAbsent(String messageStr, List<dynamic> args);')
    ..writeln()
    ..writeln('class MessageLookup extends MessageLookupByLibrary {')
    ..writeln("  String get localeName => '$locale';")
    ..writeln()
    ..writeln('  final messages = _notInlinedMessages(_notInlinedMessages);')
    ..writeln('  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{');

  for (final key in keys) {
    buffer.writeln(
      '    "$key": MessageLookupByLibrary.simpleMessage('
      '"${_escapeDoubleQuoted(messages[key]!)}"),',
    );
  }

  buffer
    ..writeln('  };')
    ..writeln('}');

  return buffer.toString();
}

String _buildMessagesAll() {
  final buffer = StringBuffer()
    ..writeln('// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart')
    ..writeln('// This is a library that looks up messages for specific locales by')
    ..writeln('// delegating to the appropriate library.')
    ..writeln()
    ..writeln('// Ignore issues from commonly used lints in this file.')
    ..writeln('// ignore_for_file:implementation_imports, file_names, unnecessary_new')
    ..writeln('// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering')
    ..writeln('// ignore_for_file:argument_type_not_assignable, invalid_assignment')
    ..writeln('// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases')
    ..writeln('// ignore_for_file:comment_references')
    ..writeln()
    ..writeln("import 'dart:async';")
    ..writeln()
    ..writeln("import 'package:flutter/foundation.dart';")
    ..writeln("import 'package:intl/intl.dart';")
    ..writeln("import 'package:intl/message_lookup_by_library.dart';")
    ..writeln("import 'package:intl/src/intl_helpers.dart';")
    ..writeln();

  for (final locale in _locales) {
    buffer.writeln("import 'messages_$locale.dart' as messages_$locale;");
  }

  buffer
    ..writeln()
    ..writeln('typedef Future<dynamic> LibraryLoader();')
    ..writeln('Map<String, LibraryLoader> _deferredLibraries = {');

  for (final locale in _locales) {
    buffer.writeln("  '$locale': () => new SynchronousFuture(null),");
  }

  buffer
    ..writeln('};')
    ..writeln()
    ..writeln('MessageLookupByLibrary? _findExact(String localeName) {')
    ..writeln('  switch (localeName) {');

  for (final locale in _locales) {
    buffer
      ..writeln("    case '$locale':")
      ..writeln('      return messages_$locale.messages;');
  }

  buffer
    ..writeln('    default:')
    ..writeln('      return null;')
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('/// User programs should call this before using [localeName] for messages.')
    ..writeln('Future<bool> initializeMessages(String localeName) {')
    ..writeln('  var availableLocale = Intl.verifiedLocale(')
    ..writeln('    localeName,')
    ..writeln('    (locale) => _deferredLibraries[locale] != null,')
    ..writeln('    onFailure: (_) => null,')
    ..writeln('  );')
    ..writeln('  if (availableLocale == null) {')
    ..writeln('    return new SynchronousFuture(false);')
    ..writeln('  }')
    ..writeln('  var lib = _deferredLibraries[availableLocale];')
    ..writeln('  lib == null ? new SynchronousFuture(false) : lib();')
    ..writeln('  initializeInternalMessageLookup(() => new CompositeMessageLookup());')
    ..writeln('  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);')
    ..writeln('  return new SynchronousFuture(true);')
    ..writeln('}')
    ..writeln()
    ..writeln('bool _messagesExistFor(String locale) {')
    ..writeln('  try {')
    ..writeln('    return _findExact(locale) != null;')
    ..writeln('  } catch (e) {')
    ..writeln('    return false;')
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {')
    ..writeln('  var actualLocale = Intl.verifiedLocale(')
    ..writeln('    locale,')
    ..writeln('    _messagesExistFor,')
    ..writeln('    onFailure: (_) => null,')
    ..writeln('  );')
    ..writeln('  if (actualLocale == null) return null;')
    ..writeln('  return _findExact(actualLocale);')
    ..writeln('}');

  return buffer.toString();
}
