import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.banner,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            right: 12,
            top: 14,
            bottom: 0,
            child: Image.asset(
              'assets/images/banner_img.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.62,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(23, 23, 0, 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.sprout,
                        color: Color(0xff736082),
                        size: 16,
                      ),
                      Gap(5),
                      Flexible(
                        child: Text(
                          'Small steps, real growth',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff736082),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Better habits.\nA happier you.',
                      style: TextStyle(
                        color: Color(0xff4F4068),
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  Gap(8),
                  Text(
                    'A little effort today. A little closer to the person you want to be.',
                    style: TextStyle(
                      color: Color(0xff736082),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
