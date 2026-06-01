/// Describes a self-contained group of generated `lib/` files, the folders they
/// live in, the pub packages they need, and the other modules they depend on.
///
/// `init` resolves a set of selected [Module]s (expanding [dependsOn]), creates
/// the folders, writes the files, and adds the union of all packages.
class Module {
  /// Stable identifier used on the command line (e.g. `config`, `widgets`).
  final String key;

  /// Human-readable title shown in prompts and `--list`.
  final String title;

  /// One-line explanation of what the module provides.
  final String description;

  /// Directories (relative to the project root) created for this module.
  final List<String> folders;

  /// Map of `path -> file contents` written for this module.
  final Map<String, String> files;

  /// Runtime dependencies added to `dependencies:`.
  final List<String> packages;

  /// Dev dependencies added to `dev_dependencies:`.
  final List<String> devPackages;

  /// Keys of other modules this one imports from; pulled in automatically.
  final List<String> dependsOn;

  const Module({
    required this.key,
    required this.title,
    required this.description,
    this.folders = const [],
    this.files = const {},
    this.packages = const [],
    this.devPackages = const [],
    this.dependsOn = const [],
  });
}
