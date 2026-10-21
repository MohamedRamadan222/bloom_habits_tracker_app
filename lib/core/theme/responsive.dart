import 'package:flutter/material.dart';

/// Small-screen comfort helpers (Phase B).
///
/// Anything below 360dp logical width counts as compact: side padding
/// shrinks so content keeps room to breathe, and dense grids drop to
/// a single column instead of squeezing.
extension ResponsiveContext on BuildContext {
  bool get isCompact => MediaQuery.sizeOf(this).width < 360;

  double get gutter => isCompact ? 16.0 : 24.0;
}

/// Caps content width on tablets/landscape so lines and cards don't
/// stretch edge-to-edge. No-op on phones (viewport < 640dp).
class CenteredContent extends StatelessWidget {
  final Widget child;

  const CenteredContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: child,
        ),
      ),
    );
  }
}
