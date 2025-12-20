import 'package:flutter/material.dart';

/// Standard scaffold wrapper for consistent layout and spacing
/// 
/// Features:
/// - Consistent padding (AppSpacing.md)
/// - SafeArea handling
/// - Optional scroll support
/// - Off-white/light grey background
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool enableScroll;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.enableScroll = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Apply padding if specified
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // Wrap in scroll view if enabled
    if (enableScroll) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: content,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

