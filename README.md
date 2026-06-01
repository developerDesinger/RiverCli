
# Riverpod CLI

A command-line tool to automate the creation of a feature structure in a Flutter project using the Riverpod state management package. This tool helps you generate necessary folders and files for each feature (such as controllers, bindings, and views) and integrates the new feature with your app's routing system using `go_router`.

## Features

- **Scaffold a Modular Project Structure**: Initialize your project with `river_cli init` and opt into reusable modules (config, utils, extensions, widgets, networking, storage) — only the files and packages you pick are added.
- **Generate Page Feature**: Easily create a new feature page with a controller, binding, and view using `river_cli create page:<page_name>`.
- **Generate Folder Structure**: Automatically creates folders like `controllers`, `bindings`, and `views` for each new feature.
- **Generate Files**: Creates the necessary Dart files with basic boilerplate code, including a controller, binding, and view.
- **Integrate with GoRouter**: Adds the new page as a route in the `GoRouter` configuration, along with the corresponding import.
- **Support for Riverpod**: Integrates the Riverpod controller into each feature.

## Installation

### 1. Install CLI

Ensure you have Dart and Flutter installed. Navigate to the project folder and run:

```bash
dart pub global activate river_cli
```


### 2. Run the CLI

Once everything is set up, you can use the following commands.


## Commands

### 1. `Initialize a Modular Project Structure`

`init` scaffolds commonly-used `lib/` files, folders, and packages into your
Flutter project. The reusable code is grouped into **modules** that you opt into
— interactively or with flags. Only the selected modules' files and packages are
added, and existing files are **skipped** (never overwritten) unless you pass
`--force`. Packages are installed with `flutter pub add`, so versions are
resolved to match your project's Dart/Flutter SDK.

```bash
river_cli init            # interactive: prompts Yes/No per module
river_cli init --all      # everything
river_cli init --minimal  # just the core (entry point, routing, home feature)
river_cli init --modules config,utils,widgets
```

#### Available modules

| Module       | What it adds | Packages |
|--------------|--------------|----------|
| `core` *(always)* | `main.dart`, `go_router` routing, and a sample Riverpod home feature + the base `lib/` folder tree | `flutter_riverpod`, `riverpod`, `go_router` |
| `config`     | `AppColors` (with a runtime-swappable primary), `AppTextStyles`, `AppConstants`, `AppStrings`, `Globals` + `.env` loading, dev/prod `AppEnvironment`, `LocalDataKey` enum | `sizer`, `google_fonts`, `flutter_dotenv` |
| `utils`      | `Utils` (asset paths, date formatting, toasts, snackbars, URL launching), `Validators`, date helpers, keyboard helpers | `intl`, `fluttertoast`, `url_launcher` |
| `extensions` | `num.height` / `.width`, `Color.withOpacityValue`, `DateTime.weekOfYear` | — |
| `widgets`    | `MyText`, `CustomButton`, `MyContainer`, `InputTextField`, asset image/icon, refresh indicator, error banner, empty state, loading spinner | `google_fonts`, `sizer` |
| `network`    | Dio `APIProvider` (get/post/put/patch/delete/multipart, bearer auth, typed errors), `APIRequestRepresentable`, `ApiEndPoints`, exceptions, `BaseRepository` + sample | `dio` |
| `storage`    | `LocalDB` (typed SharedPreferences wrapper + Riverpod providers), `SecureStorageService` | `shared_preferences`, `flutter_secure_storage` |

Modules that depend on others pull them in automatically (e.g. `widgets`
requires `config`, `utils`, and `extensions`).

#### Init options

| Flag | Description |
|------|-------------|
| `-a`, `--all` | Include every optional module |
| `--minimal` | Only the core module |
| `-m`, `--modules <a,b,c>` | Include the listed modules (comma-separated) |
| `-y`, `--yes` | Non-interactive; with no selection, includes all modules |
| `-f`, `--force` | Overwrite files that already exist |
| `--no-pub-get` | Do not run `flutter pub add` / `pub get` |
| `-l`, `--list` | List available modules and exit |
| `-h`, `--help` | Show init help |

Run `river_cli init --list` to see the modules available in your installed version.

### 2. `Create Page`

This command generates the feature for a specific page, including the controller, binding, and view files, as well as updating the route configuration.

```bash
river_cli create page:<page_name> --path lib/features
```

OR

```bash
river_cli create page:<page_name>
```

For example, if you want to create a feature called `profile`, run:

```bash
river_cli create page:profile --path lib/features
```

OR

```bash
river_cli create page:profile
```

This will generate the following structure:

```
lib/features/profile/
  ├── controllers/profile_controller.dart
  ├── bindings/profile_binding.dart
  └── views/profile_view.dart
```

It will also add the appropriate route to the `GoRouter` configuration in `lib/routes.dart`.


### 3. `Create Screen Without Route Registration`

This command generates the feature for a specific page, including the controller, binding, and view files without route registration.

```bash
river_cli create screen:<page_name> --path lib/features
```

## Example

Running the command for `profile` will generate the following:

### 1. Files

- `lib/features/profile/controllers/profile_controller.dart`
- `lib/features/profile/bindings/profile_binding.dart`
- `lib/features/profile/views/profile_view.dart`


## License

This project is licensed under the MIT License.

---

### **Note:**  
This is a basic CLI tool to help automate the process of adding new features to your app with Riverpod. You can further extend and modify it according to your project's requirements.

---

## Developers

- [Tariq Malik](https://github.com/tariqarbi03)
- [Ahtsham Mehboob](https://github.com/Ahtsham0715)

