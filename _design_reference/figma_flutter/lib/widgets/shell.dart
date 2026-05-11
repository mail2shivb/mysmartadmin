import 'package:flutter/material.dart';
import '../theme.dart';

// ============ HEADERS ============

class SlackStyleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? searchHint;
  final Widget? trailing;
  final VoidCallback? onBack;

  const SlackStyleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint,
    this.trailing,
    this.onBack,
  });

  @override
  Size get preferredSize {
    double h = 110;
    if (subtitle != null) h += 22;
    if (searchHint != null) h += 56;
    return Size.fromHeight(h);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 26),
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (onBack != null) const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 13)),
          ],
          if (searchHint != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(searchHint!, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const HeaderIcon({super.key, required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class SimpleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  const SimpleHeader({super.key, required this.title, this.subtitle, this.onBack, this.trailing});

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 76 : 96);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 48, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(icon: const Icon(Icons.chevron_left, color: AppColors.deep), onPressed: onBack)
          else
            const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ============ ROUNDED CONTENT SHEET ============

class RoundedContentSheet extends StatelessWidget {
  final Widget child;
  const RoundedContentSheet({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.sheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: child,
      ),
    );
  }
}

// ============ FILTER CHIPS ============

class FilterChipRow extends StatelessWidget {
  final List<String> chips;
  final String active;
  final ValueChanged<String> onChange;
  const FilterChipRow({super.key, required this.chips, required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          final on = c == active;
          return GestureDetector(
            onTap: () => onChange(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: on ? AppColors.primary : AppColors.lavPale,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: on ? AppColors.primary : AppColors.lavBorder),
              ),
              child: Text(
                c,
                style: TextStyle(
                  color: on ? Colors.white : AppColors.deep,
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

// ============ CATEGORY CAROUSEL ============

class CategoryCarousel extends StatelessWidget {
  final List<({String label, IconData icon})> items;
  final ValueChanged<String>? onTap;
  const CategoryCarousel({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final it = items[i];
          return GestureDetector(
            onTap: () => onTap?.call(it.label),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.lavPale,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lavBorder),
                  ),
                  child: Icon(it.icon, color: AppColors.royal, size: 24),
                ),
                const SizedBox(height: 6),
                Text(it.label, style: const TextStyle(fontSize: 11, color: AppColors.text)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============ STATUS BADGE ============

enum BadgeKind { active, review, expiring, urgent, draft, info, success, due }

class StatusBadge extends StatelessWidget {
  final BadgeKind kind;
  final String label;
  const StatusBadge({super.key, required this.kind, required this.label});

  @override
  Widget build(BuildContext context) {
    final spec = switch (kind) {
      BadgeKind.active => (AppColors.lavPale, AppColors.royal),
      BadgeKind.review => (const Color(0xFFFFF4DD), const Color(0xFF9A6500)),
      BadgeKind.expiring => (const Color(0xFFFFEAD6), const Color(0xFFA85A00)),
      BadgeKind.urgent => (const Color(0xFFFFE3E3), AppColors.urgent),
      BadgeKind.draft => (const Color(0xFFEFEAF5), AppColors.text2),
      BadgeKind.info => (const Color(0xFFE1ECFF), AppColors.info),
      BadgeKind.success => (const Color(0xFFD8F5E6), AppColors.success),
      BadgeKind.due => (const Color(0xFFFFEAD6), const Color(0xFFA85A00)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: spec.$1, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: spec.$2, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

// ============ LIST ROW ============

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
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lavPale,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lavBorder),
                ),
                child: Icon(icon, color: AppColors.royal, size: 20),
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
                          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (badge != null) ...[const SizedBox(width: 8), badge!],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.text2, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!
            else const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ============ CARD ============

class LCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const LCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lavBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

// ============ SECTION TITLE ============

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionTitle(this.title, {super.key, this.action});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600))),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ============ BUTTONS ============

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : AppColors.purpleButton,
          color: onPressed == null ? const Color(0xFFC9B8E8) : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: onPressed == null
              ? null
              : [BoxShadow(color: AppColors.royal.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const GhostButton({super.key, required this.label, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.lavPale,
          foregroundColor: AppColors.deep,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: const BorderSide(color: AppColors.lavBorder),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ============ FORM FIELD ============

class LField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final bool obscure;
  const LField({super.key, required this.label, this.hint, this.initialValue, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
          ),
          TextFormField(
            initialValue: initialValue,
            obscureText: obscure,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint ?? label,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.lavSurface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.lavBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.lavBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ OTP ============

class OTPInput extends StatelessWidget {
  final int length;
  const OTPInput({super.key, this.length = 6});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        return Container(
          width: 46, height: 50,
          decoration: BoxDecoration(
            color: AppColors.lavSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lavBorder),
          ),
          alignment: Alignment.center,
          child: Text(i < 3 ? '•' : '', style: const TextStyle(fontSize: 18, color: AppColors.text)),
        );
      }),
    );
  }
}

// ============ FIXED BOTTOM NAV ============

class FixedBottomNavBar extends StatelessWidget {
  final int activeIndex; // -1 means none
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const FixedBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.home_rounded, 'Home'),
      (Icons.lock_outline_rounded, 'Vault'),
      null,
      (Icons.notifications_none_rounded, 'Reminders'),
      (Icons.bar_chart_rounded, 'Reports'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [BoxShadow(color: Color(0x0F5B1B73), blurRadius: 16, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (i) {
          if (i == 2) {
            return GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.action,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.action.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
              ),
            );
          }
          final t = tabs[i]!;
          final on = activeIndex == i;
          return InkWell(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.$1, size: 22, color: on ? AppColors.primary : AppColors.textMuted),
                  const SizedBox(height: 2),
                  Text(t.$2, style: TextStyle(fontSize: 10, color: on ? AppColors.primary : AppColors.textMuted)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============ APP SCAFFOLD ============

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? header;
  final Widget body;
  final int activeTab; // 0 home, 1 vault, 3 reminders, 4 reports, -1 none
  final bool showBottomNav;

  const AppScaffold({
    super.key,
    this.header,
    required this.body,
    this.activeTab = -1,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          if (header != null) header!,
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: showBottomNav
          ? FixedBottomNavBar(
              activeIndex: activeTab,
              onTap: (i) => _navTab(context, i),
              onAdd: () => showAddActionSheet(context),
            )
          : null,
    );
  }
}

void _navTab(BuildContext context, int i) {
  switch (i) {
    case 0: Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false); break;
    case 1: Navigator.of(context).pushNamed('/vault'); break;
    case 3: Navigator.of(context).pushNamed('/reminders'); break;
    case 4: Navigator.of(context).pushNamed('/reports'); break;
  }
}

// ============ AUTH SCAFFOLD ============

class AuthScaffold extends StatelessWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg, AppColors.lavSurface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lavBorder),
        boxShadow: [BoxShadow(color: AppColors.plum.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: child,
    );
  }
}

class SecureChip extends StatelessWidget {
  final String label;
  const SecureChip({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lavPale,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lavBorder),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.deep, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

// ============ ADD ACTION SHEET ============

void showAddActionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    barrierColor: Colors.black.withOpacity(0.45),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      final items = [
        (Icons.document_scanner_outlined, 'Scan Document', 'Capture and extract details from a document', '/add-record'),
        (Icons.camera_alt_outlined, 'Take a Picture', 'Photograph a document, bill, policy, warranty, or task paperwork', '/add-record'),
        (Icons.image_outlined, 'Choose from Library', 'Select an image from photos', '/add-record'),
        (Icons.upload_file_outlined, 'Import from Files', 'Add PDF, image, checklist, or saved document', '/add-record'),
        (Icons.edit_note_outlined, 'Add Manually', 'Enter details without uploading anything', '/add-record'),
        (Icons.notifications_active_outlined, 'Add Reminder', 'Create renewal, expiry, bill, review, or follow-up reminder', '/add-reminder'),
        (Icons.checklist_rounded, 'Add Task', 'Create personal, household, work, or shared task', '/add-task'),
        (Icons.group_outlined, 'Add Shared Item', 'Family bill, trip cost, responsibility, shared task, or shared record', '/add-shared'),
      ];
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(color: AppColors.lavBorder, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const Text('What would you like to add?', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Scan, upload, or create a record manually.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
            const SizedBox(height: 14),
            ...items.map((it) => InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushNamed(it.$4);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.lavPale,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lavBorder),
                          ),
                          child: Icon(it.$1, color: AppColors.royal, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.$2, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(it.$3, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.lavPale,
                  foregroundColor: AppColors.deep,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    },
  );
}
