import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CloseButtonSheet extends StatelessWidget {
  final VoidCallback onTap;

  const CloseButtonSheet({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
        ),
      ),
    );
  }
}