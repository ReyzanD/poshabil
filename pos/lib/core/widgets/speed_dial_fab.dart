import 'dart:math';

import 'package:flutter/material.dart';

class SpeedDialAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

/// A floating action button that expands upward into a column of mini action
/// buttons.  The parent is responsible for rendering the backdrop overlay.
class SpeedDialFab extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final bool isOpen;
  final ValueChanged<bool>? onOpenChanged;

  const SpeedDialFab({
    super.key,
    required this.actions,
    this.isOpen = false,
    this.onOpenChanged,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;
  bool _internalOpen = false;

  static const double _actionSize = 44;
  static const double _spacing = 12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _rotateAnim = Tween(begin: 0.0, end: pi / 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isOpen) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SpeedDialFab old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen && widget.onOpenChanged != null) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _effectiveOpen => widget.onOpenChanged != null ? widget.isOpen : _internalOpen;

  void _toggle() {
    final newOpen = widget.onOpenChanged != null
        ? !widget.isOpen
        : !_internalOpen;
    if (widget.onOpenChanged != null) {
      widget.onOpenChanged!(newOpen);
    } else {
      setState(() => _internalOpen = newOpen);
    }
    if (newOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void close() {
    if (_effectiveOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final open = _effectiveOpen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expandable action buttons
        for (int i = widget.actions.length - 1; i >= 0; i--) ...[
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: 1.0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: _spacing),
              child: _buildAction(context, widget.actions[i]),
            ),
          ),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: open
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          child: AnimatedBuilder(
            animation: _rotateAnim,
            builder: (context, _) => Transform.rotate(
              angle: _rotateAnim.value,
              child: Icon(
                open ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context, SpeedDialAction action) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        close();
        action.onPressed();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label shown to the LEFT of the icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              action.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Circular icon button
          Container(
            width: _actionSize,
            height: _actionSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              action.icon,
              size: 22,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
