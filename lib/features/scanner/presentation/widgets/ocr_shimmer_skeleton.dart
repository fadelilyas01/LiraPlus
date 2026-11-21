import 'package:flutter/material.dart';

/// Skeleton loader animé reproduisant la mise en page d'un livre en cours de numérisation
class OcrShimmerSkeleton extends StatefulWidget {
  final Color surfaceColor;
  final Color highlightColor;

  const OcrShimmerSkeleton({
    super.key,
    required this.surfaceColor,
    required this.highlightColor,
  });

  @override
  State<OcrShimmerSkeleton> createState() => _OcrShimmerSkeletonState();
}

class _OcrShimmerSkeletonState extends State<OcrShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final opacity = 0.35 + (_animation.value * 0.45);

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.highlightColor.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSkeletonBar(
                      widthFactor: 0.45, height: 16, opacity: opacity),
                ],
              ),
              const SizedBox(height: 20),
              _buildSkeletonBar(
                  widthFactor: 0.95, height: 14, opacity: opacity),
              const SizedBox(height: 10),
              _buildSkeletonBar(
                  widthFactor: 0.88, height: 14, opacity: opacity),
              const SizedBox(height: 10),
              _buildSkeletonBar(
                  widthFactor: 0.75, height: 14, opacity: opacity),
              const SizedBox(height: 10),
              _buildSkeletonBar(
                  widthFactor: 0.60, height: 14, opacity: opacity),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Extraction du texte français sur l\'appareil...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.highlightColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBar({
    required double widthFactor,
    required double height,
    required double opacity,
  }) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: widget.highlightColor.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
