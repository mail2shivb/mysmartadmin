// B4.3.1 STATUS: IMPLEMENTED

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
  final bool showAddAction;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.enableScroll = false,
    this.padding,
    this.showAddAction = false,
    this.useSafeArea = true,
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

    final effectiveAppBar = _buildEffectiveAppBar(context);

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
          appBar: effectiveAppBar,
          body: useSafeArea ? SafeArea(child: content) : content,
          // B4.3.1: canonical "+" lives in AppBar, so suppress FABs.
          floatingActionButton: null,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildEffectiveAppBar(BuildContext context) {
    if (!showAddAction) return appBar;
    final base = appBar;
    if (base is! AppBar) return base;

    final theme = Theme.of(context);
    final addButton = IconButton(
      icon: const Icon(Icons.add),
      color: theme.colorScheme.primary, // #1E6FD9 in light theme
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const _AddDocumentEntryScreen(),
          ),
        );
      },
      tooltip: 'Add Document',
    );

    final existingActions = base.actions ?? const <Widget>[];

    return AppBar(
      leading: base.leading,
      automaticallyImplyLeading: base.automaticallyImplyLeading,
      title: base.title,
      centerTitle: base.centerTitle,
      actions: [...existingActions, addButton],
      flexibleSpace: base.flexibleSpace,
      bottom: base.bottom,
      elevation: base.elevation,
      scrolledUnderElevation: base.scrolledUnderElevation,
      shadowColor: base.shadowColor,
      surfaceTintColor: base.surfaceTintColor,
      backgroundColor: base.backgroundColor,
      foregroundColor: base.foregroundColor,
      iconTheme: base.iconTheme,
      actionsIconTheme: base.actionsIconTheme,
      primary: base.primary,
      titleSpacing: base.titleSpacing,
      toolbarOpacity: base.toolbarOpacity,
      bottomOpacity: base.bottomOpacity,
      toolbarHeight: base.toolbarHeight,
      shape: base.shape,
      clipBehavior: base.clipBehavior,
      systemOverlayStyle: base.systemOverlayStyle,
      forceMaterialTransparency: base.forceMaterialTransparency,
    );
  }
}

class _AddDocumentEntryScreen extends StatelessWidget {
  const _AddDocumentEntryScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add a Document'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              _AddDocumentOptionCard(
                icon: Icons.document_scanner_outlined,
                title: 'Scan a Document',
              ),
              SizedBox(height: 12),
              _AddDocumentOptionCard(
                icon: Icons.upload_file_outlined,
                title: 'Upload a File',
              ),
              SizedBox(height: 12),
              _AddDocumentOptionCard(
                icon: Icons.edit_outlined,
                title: 'Enter Details Manually',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDocumentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _AddDocumentOptionCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        // B4.3.1: chooser only — no branching here.
        onTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}

