import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/proto_theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// L WIDGETS — Figma prototype design system for LedgerAI
// ─────────────────────────────────────────────────────────────────────────────

// ── LScreen ──────────────────────────────────────────────────────────────────

/// Full-screen shell for SUB-SCREENS (push routes outside the shell).
/// Uses Scaffold(backgroundColor: purple) + Column so it works in any
/// navigator context — root or shell.
///
/// Tab screens (Home, Vault, Reminders, Reports) do NOT use LScreen;
/// they return content only and ShellScaffold wraps them.
class LScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? searchHint;
  final VoidCallback? onSearchTap;
  final Widget? trailing;
  final VoidCallback? onBack;
  final Widget child;

  const LScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint,
    this.onSearchTap,
    this.trailing,
    this.onBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF7B2CBF),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              title: title,
              subtitle: subtitle,
              searchHint: searchHint,
              onSearchTap: onSearchTap,
              trailing: trailing,
              onBack: onBack,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? searchHint;
  final VoidCallback? onSearchTap;
  final Widget? trailing;
  final VoidCallback? onBack;

  const _Header({
    required this.title,
    this.subtitle,
    this.searchHint,
    this.onSearchTap,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, searchHint != null ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                GestureDetector(
                  onTap: onBack,
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 13,
              ),
            ),
          ],
          if (searchHint != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      searchHint!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── HeaderIcon ────────────────────────────────────────────────────────────────

class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const HeaderIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── SimpleHeader ──────────────────────────────────────────────────────────────

/// Plain white header for sub-screens (not main tabs).
class SimpleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  const SimpleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? 76 : 96);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.fromLTRB(
          12, MediaQuery.of(context).padding.top + 8, 12, 14),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.deepPurple),
              onPressed: onBack,
            )
          else
            const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── LCard ─────────────────────────────────────────────────────────────────────

class LCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const LCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── StatusBadge ───────────────────────────────────────────────────────────────

enum BadgeKind { active, review, expiring, urgent, draft, info, success, due }

class StatusBadge extends StatelessWidget {
  final BadgeKind kind;
  final String label;

  const StatusBadge(
      {super.key, required this.kind, required this.label});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      BadgeKind.active => (AppColors.paleLavender, AppColors.royalPurple),
      BadgeKind.review =>
        (const Color(0xFFFFF4DD), const Color(0xFF9A6500)),
      BadgeKind.expiring =>
        (const Color(0xFFFFEAD6), const Color(0xFFA85A00)),
      BadgeKind.urgent =>
        (const Color(0xFFFFE3E3), AppColors.error),
      BadgeKind.draft =>
        (const Color(0xFFEFEAF5), AppColors.textSecondary),
      BadgeKind.info =>
        (const Color(0xFFE1ECFF), AppColors.info),
      BadgeKind.success =>
        (const Color(0xFFD8F5E6), AppColors.success),
      BadgeKind.due =>
        (const Color(0xFFFFEAD6), const Color(0xFFA85A00)),
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(
            color: fg, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── ListRow ───────────────────────────────────────────────────────────────────

class ListRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ListRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.paleLavender,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.royalPurple, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        badge!,
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── SectionTitle ──────────────────────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? action;

  const SectionTitle(this.text, {super.key, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ── FilterChipRow ─────────────────────────────────────────────────────────────

class FilterChipRow extends StatelessWidget {
  final List<String> chips;
  final String active;
  final ValueChanged<String> onChange;

  const FilterChipRow({
    super.key,
    required this.chips,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context2, index2) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          final on = c == active;
          return GestureDetector(
            onTap: () => onChange(c),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: on
                    ? AppColors.primaryPurple
                    : AppColors.paleLavender,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: on
                      ? AppColors.primaryPurple
                      : AppColors.border,
                ),
              ),
              child: Text(
                c,
                style: TextStyle(
                  color: on ? Colors.white : AppColors.deepPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── CategoryCarousel ──────────────────────────────────────────────────────────

class CategoryCarousel extends StatelessWidget {
  final List<({String label, IconData icon, String id})> items;
  final ValueChanged<String>? onTap;

  const CategoryCarousel({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context2, index2) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final it = items[i];
          return GestureDetector(
            onTap: () => onTap?.call(it.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.paleLavender,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(it.icon,
                      color: AppColors.royalPurple, size: 24),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 60,
                  child: Text(
                    it.label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatCard(
      {super.key,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LPrimaryButton ────────────────────────────────────────────────────────────

class LPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const LPrimaryButton(
      {super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              onPressed == null ? null : AppColors.purpleButton,
          color: onPressed == null
              ? const Color(0xFFC9B8E8)
              : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.royalPurple
                        .withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── LGhostButton ──────────────────────────────────────────────────────────────

class LGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const LGhostButton(
      {super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.paleLavender,
          foregroundColor: AppColors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── LField ────────────────────────────────────────────────────────────────────

class LField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final bool obscure;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const LField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.obscure = false,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          TextFormField(
            controller: controller,
            initialValue:
                controller == null ? initialValue : null,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint ?? label,
              hintStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.softLavender,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.primaryPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── LEmptyState ───────────────────────────────────────────────────────────────

class LEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const LEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.paleLavender,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                color: AppColors.royalPurple, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
