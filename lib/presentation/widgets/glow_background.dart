import 'dart:ui';
import 'package:flutter/material.dart';

class GlowBackground extends StatelessWidget {
  final Widget child;
  final Color secondColor;
  final bool isDark;

  const GlowBackground({
    super.key,
    required this.child,
    required this.secondColor,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // We want massive blobs that cover most of the screen
    final double blobSize = size.width * 1.5;

    return Stack(
      children: [
        // 1. Base Background
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),

        // 2. Top-Left Giant Blob
        Positioned(
          top: -blobSize * 0.4,
          left: -blobSize * 0.4,
          child: Container(
            width: blobSize,
            height: blobSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondColor.withValues(alpha: isDark ? 0.3 : 0.4),
                  secondColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // 3. Bottom-Right Giant Blob
        Positioned(
          bottom: -blobSize * 0.4,
          right: -blobSize * 0.4,
          child: Container(
            width: blobSize,
            height: blobSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondColor.withValues(alpha: isDark ? 0.25 : 0.35),
                  secondColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // 4. Mesh Blur (Diffuses everything)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // 5. Content
        child,
      ],
    );
  }
}
