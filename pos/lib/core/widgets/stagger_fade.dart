import 'package:flutter/material.dart';

class StaggerFade extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayPerItem;

  const StaggerFade({
    super.key,
    required this.child,
    required this.index,
    this.delayPerItem = const Duration(milliseconds: 60),
  });

  @override
  State<StaggerFade> createState() => _StaggerFadeState();
}

class _StaggerFadeState extends State<StaggerFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    Future.delayed(widget.delayPerItem * widget.index, _controller.forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: _slide.value * MediaQuery.of(context).size.height,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}