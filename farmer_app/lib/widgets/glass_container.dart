import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;

  final EdgeInsets padding;

  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),

        borderRadius: BorderRadius.circular(borderRadius),

        border: Border.all(color: Colors.white.withOpacity(0.2)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),

            blurRadius: 20,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: child,
    );
  }
}
