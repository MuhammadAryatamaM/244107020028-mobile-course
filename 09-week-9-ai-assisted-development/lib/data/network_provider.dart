import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setOffline(bool val) => state = val;
}

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);
