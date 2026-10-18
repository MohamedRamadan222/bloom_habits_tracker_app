import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

enum PageHeaderVariant { home, page }

class PageHeader extends StatelessWidget {
  final PageHeaderVariant variant;
  final String title;
  final String subtitle;
  final VoidCallback? onActionPressed;

  const PageHeader.home({
    super.key,
    required this.title,
    required this.subtitle,
    this.onActionPressed,
  }) : variant = PageHeaderVariant.home;

  const PageHeader.page({
    super.key,
    required this.title,
    required this.subtitle,
    this.onActionPressed,
  }) : variant = PageHeaderVariant.page;

  bool get _isHome => variant == PageHeaderVariant.home;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isHome) ...[
                _Subtitle(text: subtitle, showIcon: true),
                const Gap(6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -1.3,
                ),
              ),
              if (!_isHome) ...[const Gap(6), _Subtitle(text: subtitle)],
            ],
          ),
        ),
        _ActionButton(onPressed: onActionPressed),
      ],
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;
  final bool showIcon;

  const _Subtitle({required this.text, this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: TextStyle(color: AppColors.muted, fontSize: 12)),
        if (showIcon) ...[
          const Gap(10),
          const Icon(LucideIcons.sun, color: Color(0xffCA965C), size: 16),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ActionButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(LucideIcons.plus, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
