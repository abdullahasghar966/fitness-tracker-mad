import 'package:flutter/material.dart';

class StaggeredList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 70),
    this.itemDuration = const Duration(milliseconds: 600),
  });

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    final itemCount = widget.children.length;
    final totalDuration = widget.itemDuration +
        (widget.staggerDelay * (itemCount > 0 ? itemCount - 1 : 0));

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < itemCount; i++) {
      final startDelay =
          widget.staggerDelay.inMilliseconds * i / totalDuration.inMilliseconds;
      final endDelay = startDelay +
          widget.itemDuration.inMilliseconds / totalDuration.inMilliseconds;

      final clampedEnd = endDelay.clamp(0.0, 1.0);
      final clampedStart = startDelay.clamp(0.0, 1.0);

      final slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(clampedStart, clampedEnd, curve: Curves.easeOut),
        ),
      );

      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(clampedStart, clampedEnd, curve: Curves.easeOut),
        ),
      );

      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
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
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.children.length, (index) {
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: Transform.translate(
                offset: Offset(0, _slideAnimations[index].value),
                child: widget.children[index],
              ),
            );
          }),
        );
      },
    );
  }
}
