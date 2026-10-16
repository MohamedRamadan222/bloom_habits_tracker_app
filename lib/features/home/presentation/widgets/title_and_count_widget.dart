import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';

class TitleAndCountWidget extends StatefulWidget {
  final int count;
  final VoidCallback onPressed;

  const TitleAndCountWidget({
    super.key,
    required this.count,
    required this.onPressed,
  });

  @override
  State<TitleAndCountWidget> createState() => _TitleAndCountWidgetState();
}

class _TitleAndCountWidgetState extends State<TitleAndCountWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Today’s habits',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Gap(8),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                 widget.count.toString(),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.primaryColor,
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Manage',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                ),
              ),
              Gap(5),
              Icon(
                CupertinoIcons.forward,
                color: AppColors.primaryColor,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
