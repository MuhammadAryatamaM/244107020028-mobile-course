import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final prefs = ref.watch(prefsRepositoryProvider);
  return prefs.getLastOpened();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // Dark mode toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: darkModeAsync.value ?? false,
            onChanged: (val) {
              ref.read(darkModeProvider.notifier).toggle();
            },
          ),
          const Divider(),

          // Last opened
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Last Opened'),
            subtitle: lastOpenedAsync.when(
              data: (value) => Text(value ?? 'Never'),
              loading: () => const Text('...'),
              error: (err, _) => Text('Error: $err'),
            ),
          ),
        ],
      ),
    );
  }
}
