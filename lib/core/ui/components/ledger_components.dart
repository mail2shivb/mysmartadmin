import 'package:flutter/material.dart';

import '../tokens.dart';

/// Shared UI components adapted from the Figma/FlutterFlow prototype.
///
/// These complement the existing [AppScaffold], [AppCard], [PrimaryButton] etc.
/// Use these in new screens; do not import the _design_reference/ folder.

// ─────────────────────────────────────────────────────────────────────────────
// SlackStyleHeader
// ─────────────────────────────────────────────────────────────────────────────

/// Slack-style page header with greeting text and optional trailing action.
class SlackStyleHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SlackStyleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RoundedContentSheet
// ─────────────────────────────────────────────────────────────────────────────

/// White (or surface) card with top rounded corners — used as a content
/// sheet that floats above the canvas background.
class RoundedContentSheet extends StatelessWidget {
  final Widget child;
  final double topRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const RoundedContentSheet({
    super.key,
    required this.child,
    this.topRadius = 24,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      padding: padding,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterChipRow
// ─────────────────────────────────────────────────────────────────────────────

/// A horizontally-scrolling row of filter chips.
class FilterChipRow<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: items.map((item) {
          final isSelected = item == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: Text(label(item)),
              selected: isSelected,
              onSelected: (_) => onSelected(item),
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surfaceContainer,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoryCarouselItem / CategoryCarousel
// ─────────────────────────────────────────────────────────────────────────────

class CategoryCarouselItem {
  final String id;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final int count;

  const CategoryCarouselItem({
    required this.id,
    required this.label,
    required this.icon,
    this.iconColor,
    this.iconBackground,
    this.count = 0,
  });
}

/// Horizontally-scrolling domain/category pill carousel.
class CategoryCarousel extends StatelessWidget {
  final List<CategoryCarouselItem> items;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const CategoryCarousel({
    super.key,
    required this.items,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = item.id == selectedId;
          final bg = isSelected
              ? theme.colorScheme.primaryContainer
              : (item.iconBackground ??
                  theme.colorScheme.surfaceContainerLowest);
          final fg = isSelected
              ? theme.colorScheme.onPrimaryContainer
              : (item.iconColor ?? theme.colorScheme.onSurfaceVariant);
          return GestureDetector(
            onTap: () => onSelected(item.id),
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.35)
                      : theme.colorScheme.outline.withValues(alpha: 0.12),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: fg, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.count > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${item.count}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fg.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatusBadge
// ─────────────────────────────────────────────────────────────────────────────

enum LedgerStatusLevel { ok, warning, danger, info, neutral }

/// Compact coloured pill badge for document / record status.
class StatusBadge extends StatelessWidget {
  final String label;
  final LedgerStatusLevel level;

  const StatusBadge({
    super.key,
    required this.label,
    this.level = LedgerStatusLevel.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg) = _resolveColours(theme, level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  static (Color, Color) _resolveColours(ThemeData t, LedgerStatusLevel l) {
    final cs = t.colorScheme;
    return switch (l) {
      LedgerStatusLevel.ok => (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      LedgerStatusLevel.warning => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      LedgerStatusLevel.danger => (cs.errorContainer, cs.onErrorContainer),
      LedgerStatusLevel.info => (cs.primaryContainer, cs.onPrimaryContainer),
      LedgerStatusLevel.neutral => (cs.surfaceContainer, cs.onSurfaceVariant),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ListRow
// ─────────────────────────────────────────────────────────────────────────────

/// A standard list row with leading icon container, title, subtitle, and
/// optional trailing widget.
class ListRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const ListRow({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackground,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = iconBackground ?? cs.primaryContainer;
    final fg = iconColor ?? cs.onPrimaryContainer;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, color: fg, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!
                else if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.md + 40 + AppSpacing.md,
            color: cs.outlineVariant,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LCard  (Ledger Card — generic content card)
// ─────────────────────────────────────────────────────────────────────────────

/// Generic content card with optional header row.
class LCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleTrailing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const LCard({
    super.key,
    required this.child,
    this.title,
    this.titleTrailing,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: cs.outlineVariant,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    if (titleTrailing != null) titleTrailing!,
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GhostButton
// ─────────────────────────────────────────────────────────────────────────────

/// Outlined text button (secondary action).
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          )
        : Text(label);
    return OutlinedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SectionTitle
// ─────────────────────────────────────────────────────────────────────────────

/// Small all-caps section divider label.
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EmptyStateCard
// ─────────────────────────────────────────────────────────────────────────────

/// In-list empty state with icon, heading, and optional CTA button.
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String heading;
  final String? body;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.heading,
    this.body,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 30),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            heading,
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              body!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonLabel != null && onButtonTap != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onButtonTap,
              icon: const Icon(Icons.add, size: 16),
              label: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
