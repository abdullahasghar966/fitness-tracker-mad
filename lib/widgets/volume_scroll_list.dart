import 'package:flutter/material.dart';

/// Two animations combined:
///
/// 1. GSAP-style reveal — on first build each item slides up + fades in
///    with a staggered delay (index × 65ms).
///
/// 2. Volume / drum-wheel — while scrolling, items far from the screen
///    centre shrink (up to −10 %) and fade (up to −35 %), exactly like
///    the Dribbble "Volume" shot where cards near the focal point are
///    bold and cards at the edges recede.
///
/// Usage (replaces SingleChildScrollView):
///   VolumeScrollList(padding: ..., children: [...])
///
/// Usage inside an existing ListView.builder:
///   Pass the screen's ScrollController to VolumeListItem.
class VolumeScrollList extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;

  const VolumeScrollList({
    super.key,
    required this.children,
    this.padding,
    this.separatorBuilder,
  });

  @override
  State<VolumeScrollList> createState() => _VolumeScrollListState();
}

class _VolumeScrollListState extends State<VolumeScrollList> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemCount: widget.children.length,
      separatorBuilder: widget.separatorBuilder ??
          (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => VolumeListItem(
        key: ValueKey(index),
        scrollController: _controller,
        revealDelay: Duration(milliseconds: (index * 65).clamp(0, 400)),
        child: widget.children[index],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VolumeListItem — use this directly inside your own ListView.builder
// ─────────────────────────────────────────────────────────────────────────────

class VolumeListItem extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final Duration revealDelay;

  const VolumeListItem({
    super.key,
    required this.child,
    required this.scrollController,
    this.revealDelay = Duration.zero,
  });

  @override
  State<VolumeListItem> createState() => _VolumeListItemState();
}

class _VolumeListItemState extends State<VolumeListItem>
    with SingleTickerProviderStateMixin {
  // Key on the inner SizedBox so localToGlobal stays stable even while
  // AnimatedBuilder is rebuilding its outer builder function.
  final _key = GlobalKey();

  late final AnimationController _revealCtrl;
  late final Animation<double> _revealFade;
  late final Animation<Offset> _revealSlide;

  @override
  void initState() {
    super.initState();

    // ── GSAP-style slide-up reveal ──────────────────────────────────────
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealFade =
        CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);
    _revealSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.revealDelay, () {
      if (mounted) _revealCtrl.forward();
    });
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  // ── Volume / drum-wheel ─────────────────────────────────────────────────
  // Returns a [0 … 1] factor where 0 = at screen centre, 1 = at edge.
  double _distanceFactor() {
    if (!widget.scrollController.hasClients) return 0.0;
    final ctx = _key.currentContext;
    if (ctx == null) return 0.0;
    try {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return 0.0;
      final pos = box.localToGlobal(Offset.zero);
      final screenH = MediaQuery.of(context).size.height;
      final itemCentre = pos.dy + box.size.height / 2;
      final screenCentre = screenH / 2;
      final dist = (itemCentre - screenCentre).abs();
      // Use 55 % of half-height as the "full edge" distance so the effect
      // is noticeable without looking extreme.
      return (dist / (screenH * 0.55)).clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _revealFade,
      child: SlideTransition(
        position: _revealSlide,
        child: AnimatedBuilder(
          animation: widget.scrollController,
          child: SizedBox(key: _key, child: widget.child), // stable subtree
          builder: (ctx, child) {
            final f = _distanceFactor();
            // Items at edge: 10 % smaller, 35 % more transparent
            final scale = (1.0 - f * 0.10).clamp(0.88, 1.0);
            final opacity = (1.0 - f * 0.35).clamp(0.55, 1.0);
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: opacity, child: child),
            );
          },
        ),
      ),
    );
  }
}
