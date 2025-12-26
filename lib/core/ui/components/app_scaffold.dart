import 'package:flutter/material.dart';
import '../theme_inherited_widget.dart';

/// Standard scaffold wrapper with premium fintech-grade background
/// 
/// Features:
/// - Fixed gradient background in dark mode (Monzo/Emma style)
/// - Fixed neutral background in light mode
/// - Designer-controlled (NO user customization)
/// - SafeArea handling
/// - Optional scroll support
/// - Consistent padding
/// 
/// Dark mode: Subtle vertical gradient (#0F1117 → #141625)
/// Light mode: Solid fintech neutral (#F6F7FB)
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
    final colors = AppThemeProvider.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    // Build background - gradient in dark mode, solid in light mode
    final BoxDecoration backgroundDecoration = isDark
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.backgroundGradientStart, // #0F1117
                colors.backgroundGradientEnd,   // #141625
              ],
            ),
          )
        : BoxDecoration(
            color: colors.appBackground, // #F6F7FB
          );

    return Stack(
      children: [
        // Background: Premium gradient (dark) or solid (light)
        Positioned.fill(
          child: Container(
            decoration: backgroundDecoration,
          ),
        ),
        
        // Content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: SafeArea(
            child: content,
          ),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}

