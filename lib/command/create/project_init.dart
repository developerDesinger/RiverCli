import 'dart:io';

import '../../static/modules/modules.dart';
import '../../utils/utils.dart';
import 'init_options.dart';

/// Entry point for `river_cli init`. Resolves the selected modules (via flags
/// or interactive prompts), scaffolds their folders/files, and adds packages.
void runInit(InitOptions options) {
  if (options.help) {
    printInitHelp();
    return;
  }
  if (options.list) {
    printModuleList();
    return;
  }

  if (!File('pubspec.yaml').existsSync()) {
    print('Error: pubspec.yaml not found. '
        'Run "river_cli init" in the root of a Flutter project.');
    exit(1);
  }

  final projectName = Utils.readPackageName();
  if (projectName != null) {
    print('Initializing project: $projectName\n');
  }

  if (options.unknownFlags.isNotEmpty) {
    print('Ignoring unknown option(s): ${options.unknownFlags.join(', ')}');
  }

  final selectedKeys = _resolveSelectedKeys(options);
  final modules = resolveModules(selectedKeys);

  final autoIncluded = modules
      .where((m) => m.key != coreModule.key && !selectedKeys.contains(m.key))
      .map((m) => m.key)
      .toList();
  if (autoIncluded.isNotEmpty) {
    print('Auto-including required dependencies: ${autoIncluded.join(', ')}');
  }

  final created = <String>[];
  final skipped = <String>[];
  final overwritten = <String>[];

  for (final module in modules) {
    for (final folder in module.folders) {
      final dir = Directory(folder);
      if (!dir.existsSync()) dir.createSync(recursive: true);
    }

    module.files.forEach((path, content) {
      final file = File(path);
      final exists = file.existsSync();
      if (exists && !options.force) {
        skipped.add(path);
        return;
      }
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(_normalize(content));
      (exists ? overwritten : created).add(path);
    });
  }

  final deps = <String>{};
  final devDeps = <String>{};
  for (final module in modules) {
    deps.addAll(module.packages);
    devDeps.addAll(module.devPackages);
  }

  print('');
  Utils.addModulePackages(
    deps.toList(),
    devDeps.toList(),
    runPubGet: options.runPubGet,
  );

  _printSummary(
    modules: modules,
    created: created,
    overwritten: overwritten,
    skipped: skipped,
  );
}

/// Returns the optional module keys to install. May prompt interactively.
List<String> _resolveSelectedKeys(InitOptions options) {
  final explicit = options.explicitSelection();
  if (explicit != null) {
    final unknown = unknownModuleKeys(explicit);
    if (unknown.isNotEmpty) {
      print('Unknown module(s): ${unknown.join(', ')}. '
          'Available: ${kModules.keys.join(', ')}\n');
    }
    return explicit.where(kModules.containsKey).toList();
  }

  print('Select the modules to include (core is always added):\n');
  final selected = <String>[];
  for (final module in kOptionalModulesOrdered) {
    if (Utils.promptYesNo('  Include ${module.title}?')) {
      selected.add(module.key);
    }
  }
  print('');
  return selected;
}

/// Strips a single leading newline from a template literal.
String _normalize(String content) =>
    content.startsWith('\n') ? content.substring(1) : content;

void _printSummary({
  required List<Module> modules,
  required List<String> created,
  required List<String> overwritten,
  required List<String> skipped,
}) {
  print('\n${'=' * 48}');
  print('river_cli init complete');
  print('=' * 48);
  print('Modules: ${modules.map((m) => m.key).join(', ')}');
  print('Files created: ${created.length}');
  for (final p in created) {
    print('  + $p');
  }
  if (overwritten.isNotEmpty) {
    print('Files overwritten (--force): ${overwritten.length}');
    for (final p in overwritten) {
      print('  ~ $p');
    }
  }
  if (skipped.isNotEmpty) {
    print('Files skipped (already exist, use --force to overwrite): '
        '${skipped.length}');
    for (final p in skipped) {
      print('  = $p');
    }
  }
  print('\nNext steps:');
  print('  1. Run "flutter pub get" if it was not run automatically.');
  print('  2. Wire up generated config/services in your main.dart.');
  print('  3. Create features with: river_cli create page:<name>');
}

/// Prints the available modules (`init --list`).
void printModuleList() {
  print('river_cli init modules:\n');
  print('  core${' ' * 12}(always added) '
      '${coreModule.description}');
  for (final module in kOptionalModulesOrdered) {
    final padding = ' ' * (16 - module.key.length).clamp(1, 16);
    final deps = module.dependsOn.isEmpty
        ? ''
        : ' [needs: ${module.dependsOn.join(', ')}]';
    print('  ${module.key}$padding${module.title}$deps');
  }
}

/// Prints help for the `init` command (`init --help`).
void printInitHelp() {
  print('''
Usage: river_cli init [options]

Scaffolds commonly-used lib/ files, folders, and packages into a Flutter
project. "core" (entry point, routing, sample home feature) is always added.

Options:
  -a, --all              Include every optional module
      --minimal          Only the core module
  -m, --modules <a,b,c>  Include the listed modules (comma-separated)
  -y, --yes              Non-interactive; with no selection, includes all
  -f, --force            Overwrite files that already exist
      --no-pub-get       Do not run "flutter pub add"/"pub get"
  -l, --list             List available modules and exit
  -h, --help             Show this help and exit

Examples:
  river_cli init                       # interactive prompts
  river_cli init --all
  river_cli init --modules config,utils,widgets
  river_cli init --minimal --yes''');
}
