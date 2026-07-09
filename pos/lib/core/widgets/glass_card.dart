import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'press_scale.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? tintColor;
  final double? height;
  final VoidCallback? onTap;
  final bool loading;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.tintColor,
    this.height,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tintColor ?? theme.colorScheme.primary;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: PressScale(
        scale: onTap != null ? 0.97 : 1.0,
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surfaceContainerLowest.withAlpha(220),
                  theme.colorScheme.surfaceContainerLow.withAlpha(180),
                ],
              ),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withAlpha(60),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: padding ?? const EdgeInsets.all(16),
                        child: child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}