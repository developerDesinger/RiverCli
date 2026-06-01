import 'package:river_cli/command/create/init_options.dart';
import 'package:river_cli/static/modules/modules.dart';
import 'package:test/test.dart';

void main() {
  group('Module registry', () {
    test('exposes the expected optional modules', () {
      expect(
        kModules.keys.toSet(),
        {'config', 'utils', 'extensions', 'widgets', 'network', 'storage'},
      );
    });

    test('core is never listed as an optional module', () {
      expect(kModules.containsKey('core'), isFalse);
    });

    test('unknownModuleKeys flags only unrecognized keys', () {
      expect(unknownModuleKeys(['config', 'bogus', 'utils']), ['bogus']);
      expect(unknownModuleKeys(['widgets']), isEmpty);
    });
  });

  group('resolveModules', () {
    List<String> keysOf(List<Module> modules) =>
        modules.map((m) => m.key).toList();

    test('always includes core first', () {
      final resolved = resolveModules([]);
      expect(resolved.first.key, 'core');
    });

    test('expands transitive dependencies for widgets', () {
      final resolved = keysOf(resolveModules(['widgets']));
      expect(resolved.first, 'core');
      expect(resolved, containsAll(['config', 'utils', 'extensions', 'widgets']));
    });

    test('orders dependencies before dependents', () {
      final resolved = keysOf(resolveModules(['widgets']));
      expect(resolved.indexOf('config'), lessThan(resolved.indexOf('widgets')));
      expect(resolved.indexOf('utils'), lessThan(resolved.indexOf('widgets')));
      expect(
          resolved.indexOf('extensions'), lessThan(resolved.indexOf('widgets')));
    });

    test('network and storage pull in config', () {
      expect(keysOf(resolveModules(['network'])), containsAll(['config', 'network']));
      expect(keysOf(resolveModules(['storage'])), containsAll(['config', 'storage']));
    });

    test('does not duplicate shared dependencies', () {
      final resolved = keysOf(resolveModules(['widgets', 'network', 'storage']));
      expect(resolved.where((k) => k == 'config').length, 1);
      expect(resolved.where((k) => k == 'core').length, 1);
    });

    test('ignores unknown keys without throwing', () {
      final resolved = keysOf(resolveModules(['nope']));
      expect(resolved, ['core']);
    });
  });

  group('InitOptions.parse', () {
    test('defaults to interactive with no args', () {
      final opts = InitOptions.parse([]);
      expect(opts.wantsInteractive, isTrue);
      expect(opts.explicitSelection(), isNull);
      expect(opts.runPubGet, isTrue);
      expect(opts.force, isFalse);
    });

    test('--all selects every optional module', () {
      final opts = InitOptions.parse(['--all']);
      expect(opts.wantsInteractive, isFalse);
      expect(opts.explicitSelection()!.toSet(), kModules.keys.toSet());
    });

    test('--minimal selects no optional modules', () {
      final opts = InitOptions.parse(['--minimal']);
      expect(opts.explicitSelection(), isEmpty);
    });

    test('--modules accepts a comma-separated value', () {
      final opts = InitOptions.parse(['--modules', 'config,utils,widgets']);
      expect(opts.explicitSelection(), ['config', 'utils', 'widgets']);
    });

    test('--modules=value form is supported', () {
      final opts = InitOptions.parse(['--modules=config,network']);
      expect(opts.explicitSelection(), ['config', 'network']);
    });

    test('--yes with no selection includes all', () {
      final opts = InitOptions.parse(['--yes']);
      expect(opts.explicitSelection()!.toSet(), kModules.keys.toSet());
    });

    test('parses --force, --no-pub-get, --list, --help', () {
      final opts =
          InitOptions.parse(['--force', '--no-pub-get', '--list', '--help']);
      expect(opts.force, isTrue);
      expect(opts.runPubGet, isFalse);
      expect(opts.list, isTrue);
      expect(opts.help, isTrue);
    });

    test('collects unknown flags', () {
      final opts = InitOptions.parse(['--bogus', '--all']);
      expect(opts.unknownFlags, ['--bogus']);
      expect(opts.all, isTrue);
    });
  });
}
