import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.onTap});

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: cardShadow,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(AppRadius.card), onTap: onTap, child: box),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return AppColors.border;
            if (s.contains(WidgetState.pressed)) return AppColors.accentPressed;
            return AppColors.accentFill;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? AppColors.textTertiary : Colors.white,
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontFamily: 'BarlowCondensed', fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 20)],
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.expand = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 48),
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        foregroundColor: AppColors.textPrimary,
        textStyle: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 16, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: AppColors.accentFill), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

enum ChipTone { accent, success, warning, danger, info, neutral }

class TintChip extends StatelessWidget {
  const TintChip(this.text, {super.key, this.tone = ChipTone.accent, this.icon});

  final String text;
  final ChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      ChipTone.accent => (AppColors.accentTint, AppColors.accentFill),
      ChipTone.success => (AppColors.successTint, AppColors.success),
      ChipTone.warning => (AppColors.warningTint, AppColors.warning),
      ChipTone.danger => (AppColors.dangerTint, AppColors.danger),
      ChipTone.info => (AppColors.infoTint, AppColors.info),
      ChipTone.neutral => (AppColors.surfaceAlt, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(text, style: AppText.caption(color: fg)),
        ],
      ),
    );
  }
}

/// 44px round habit toggle: outline when open, filled accent with a check
/// when done.
class HabitCheckButton extends StatelessWidget {
  const HabitCheckButton({super.key, required this.done, required this.onTap, this.label = ''});

  final bool done;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: done,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.accentFill : Colors.white,
            border: Border.all(color: done ? AppColors.accentFill : AppColors.borderStrong, width: 2),
          ),
          child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 24) : null,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.title())),
          if (trailing != null) Text(trailing!, style: AppText.caption()),
        ],
      ),
    );
  }
}

class StreakDots extends StatelessWidget {
  const StreakDots(this.days, {super.key});

  final List<bool> days;

  @override
  Widget build(BuildContext context) {
    final done = days.where((d) => d).length;
    return Semantics(
      label: 'Weekly streak $done of 7 days',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final d in days)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: d ? AppColors.accentFill : AppColors.border,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared top header: logo mark + app name, bell on the right.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.onBell, this.title = 'Petal Path'});

  final VoidCallback? onBell;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        children: [
          Image.asset('assets/images/logo-mark.png', width: 26, height: 26),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: AppText.oswald(20, 600, color: AppColors.accentFill))),
          if (onBell != null)
            IconButton(
              key: const Key('bell'),
              tooltip: 'Notifications',
              onPressed: onBell,
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            ),
        ],
      ),
    );
  }
}

class BackHeader extends StatelessWidget {
  const BackHeader({super.key, required this.title, this.trailing, this.centerTitle = false});

  final String title;
  final Widget? trailing;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            key: const Key('back'),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(title, style: AppText.title(), textAlign: centerTitle ? TextAlign.center : TextAlign.start),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble(this.icon, {super.key, this.size = 40, this.color = AppColors.accentFill, this.bg = AppColors.accentTint});

  final IconData icon;
  final double size;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// Dark scrim so white text over photos keeps >= 4.5:1.
class PhotoScrim extends StatelessWidget {
  const PhotoScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x99000000)],
        ),
      ),
    );
  }
}

void showMockSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
}
