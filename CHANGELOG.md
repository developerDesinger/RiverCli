

## 1.1.0

- **Modular `init`**: `river_cli init` now scaffolds a curated set of reusable
  `lib/` building blocks organized into opt-in modules — `config` (colors, text
  styles, constants, strings, globals, environment switch, local keys), `utils`
  (formatting, toasts, validators, keyboard helpers), `extensions`, `widgets`
  (text, button, container, input field, asset image, refresh indicator, error
  banner, empty state, loading spinner), `network` (Dio client, request
  abstraction, typed exceptions, endpoints, repository base), and `storage`
  (SharedPreferences wrapper + secure storage). `core` (entry point, routing,
  sample home feature) is always generated.
- **Customizable**: choose modules interactively, or with flags — `--all`,
  `--minimal`, `--modules a,b,c`, `--yes` (non-interactive), `--force`
  (overwrite), `--no-pub-get`, `--list`, `--help`.
- **Safe re-runs**: existing files are skipped by default (use `--force` to
  overwrite); a summary reports created/overwritten/skipped files.
- **Smart package management**: only the selected modules' packages are added,
  via `flutter pub add` so versions resolve compatibly with the project's
  Dart/Flutter SDK. Falls back to unversioned pubspec entries when Flutter is
  not on PATH. Dependent modules are pulled in automatically.
- **Modern Riverpod API**: generated controllers/providers now use
  `Notifier` / `NotifierProvider` (compatible with Riverpod 2.x and 3.x),
  replacing the removed `StateNotifier` API.
- Bumped the CLI's own SDK constraint and dependencies for the latest Dart.

## 1.0.6

- Class names for generated pages are now always in CamelCase, even if the user provides snake_case. Only folder and file names remain in snake_case. This ensures Dart best practices for class naming.
- 'Change headline4 to headlineMedium

## 1.0.3

- Initial release of `river_cli`.
- Added support for `river_cli init` to initialize the project structure with folders and base configuration.
- Added `river_cli create page:<page_name>` command to generate a feature structure with:
  - `controllers`
  - `bindings`
  - `views`
- Integrated automatic route updates for `go_router`, including route imports and configuration.
- Enhanced feature creation with customizable paths via the `--path` flag.
- Ensured compatibility with Flutter projects using Riverpod and GoRouter.
- Introduced a user-friendly CLI interface to streamline Flutter development workflows.

