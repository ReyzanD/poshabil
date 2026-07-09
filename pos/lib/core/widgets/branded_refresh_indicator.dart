import 'package:flutter/material.dart';

class BrandedRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const BrandedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: 60,
      edgeOffset: 12,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      strokeWidth: 3,
      child: child,
    );
  }
}