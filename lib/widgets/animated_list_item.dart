import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final bool isHorizontal;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: isHorizontal ? 0.0 : 50.0,
        horizontalOffset: isHorizontal ? 50.0 : 0.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
