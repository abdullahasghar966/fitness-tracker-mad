import 'package:flutter/material.dart';

/// Each child animates in (fade + slide up) the moment it gets built —
/// meaning new items entering the viewport during scroll also animate in.
/// Delay is keyed by [index] so stagger works on initial load too.
class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDuration;

  const RevealOnScroll({
    super.key,
    required this.child,
    required this.index,
    this.baseDuration = const Duration(milliseconds: 420),
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.baseDuration);

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: clamp to max 400ms so deep items don't wait forever
    final delay = Duration(milliseconds: (widget.index * 70).clamp(0, 420));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
