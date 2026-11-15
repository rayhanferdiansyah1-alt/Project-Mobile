import 'package:flutter/material.dart';

PageRoute<T> fadeSlideRoute<T>({
  required Widget child,
  Duration duration = const Duration(milliseconds: 350),
}) => PageRouteBuilder<T>(
  transitionDuration: duration,
  pageBuilder: (context, animation, secondaryAnimation) => child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  },
);
