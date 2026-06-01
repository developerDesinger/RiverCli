import '../../models/module.dart';

/// Always generated. Provides the base folder tree, entry point, go_router
/// setup, and a working Riverpod "home" feature so a fresh project runs
/// immediately. Kept independent of every other module so `--minimal` still
/// compiles on its own.
final Module coreModule = Module(
  key: 'core',
  title: 'Core (entry point, routing, home feature)',
  description:
      'main.dart, go_router config, and a sample Riverpod home feature plus the base lib/ folder tree.',
  packages: ['flutter_riverpod', 'riverpod', 'go_router'],
  folders: [
    'lib/app/config',
    'lib/app/core',
    'lib/app/extensions',
    'lib/app/shared_widgets',
    'lib/app/utils',
    'lib/app/routes',
    'lib/data',
    'lib/data/models',
    'lib/data/provider',
    'lib/data/provider/network',
    'lib/data/repositories',
    'lib/presentation/home/controllers',
    'lib/presentation/home/views',
    'lib/presentation/home/bindings',
  ],
  files: {
    'lib/main.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes/route_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
''',
    'lib/app/routes/app_routes.dart': '''
class AppRoutes {
  static const String home = '/home';
}
''',
    'lib/app/routes/route_page.dart': '''
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../presentation/home/views/home_view.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      name: AppRoutes.home,
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
  ],
);
''',
    'lib/presentation/home/controllers/home_controller.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeController extends Notifier<int> {
  @override
  int build() {
    // Initial state (and any setup) goes here.
    return 0;
  }

  void increment() => state++;
  void decrement() {
    if (state > 0) state--;
  }
}
''',
    'lib/presentation/home/bindings/home_binding.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/home_controller.dart';

final homeControllerProvider =
    NotifierProvider<HomeController, int>(HomeController.new);
''',
    'lib/presentation/home/views/home_view.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bindings/home_binding.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home View')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final counter = ref.watch(homeControllerProvider);
                return Text(
                  'Counter: \$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final controller =
                        ref.read(homeControllerProvider.notifier);
                    return ElevatedButton(
                      onPressed: controller.decrement,
                      child: const Text('-'),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final controller =
                        ref.read(homeControllerProvider.notifier);
                    return ElevatedButton(
                      onPressed: controller.increment,
                      child: const Text('+'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
''',
  },
);
