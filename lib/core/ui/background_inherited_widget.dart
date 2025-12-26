import 'package:flutter/material.dart';
import 'background_controller.dart';

/// Provides background controller to the widget tree
/// 
/// Wraps the app and makes background style available via
/// BackgroundProvider.of(context).
class BackgroundProvider extends InheritedNotifier<BackgroundController> {
  const BackgroundProvider({
    super.key,
    required BackgroundController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Get background controller from context
  static BackgroundController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BackgroundProvider>();
    assert(provider != null, 'BackgroundProvider not found in widget tree');
    return provider!.notifier!;
  }

  @override
  bool updateShouldNotify(BackgroundProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

