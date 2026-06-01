import '../../models/module.dart';
import 'config_module.dart';
import 'core_module.dart';
import 'extensions_module.dart';
import 'network_module.dart';
import 'storage_module.dart';
import 'utils_module.dart';
import 'widgets_module.dart';

export '../../models/module.dart';
export 'core_module.dart' show coreModule;

/// Optional modules in the order they are presented (prompts and `--list`).
final List<Module> kOptionalModulesOrdered = [
  configModule,
  utilsModule,
  extensionsModule,
  widgetsModule,
  networkModule,
  storageModule,
];

/// Optional modules keyed by CLI identifier.
final Map<String, Module> kModules = {
  for (final m in kOptionalModulesOrdered) m.key: m,
};

/// Keys the user passed that don't match any known module.
List<String> unknownModuleKeys(Iterable<String> keys) =>
    keys.where((k) => !kModules.containsKey(k)).toList();

/// Expands [selectedKeys] with their transitive dependencies, always prepends
/// `core`, and returns modules in install order (dependencies before dependents,
/// no duplicates). Unknown keys are ignored here (validate separately).
List<Module> resolveModules(Iterable<String> selectedKeys) {
  final resolved = <String, Module>{};

  void add(Module module) {
    if (resolved.containsKey(module.key)) return;
    for (final depKey in module.dependsOn) {
      final dep = kModules[depKey];
      if (dep != null) add(dep);
    }
    resolved[module.key] = module;
  }

  for (final key in selectedKeys) {
    final module = kModules[key];
    if (module != null) add(module);
  }

  return [coreModule, ...resolved.values];
}
