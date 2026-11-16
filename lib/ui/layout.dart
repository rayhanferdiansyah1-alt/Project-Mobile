import 'package:flutter/material.dart';

/// Membatasi lebar konten halaman pada layar besar, tetap penuh di ponsel.
class AppContent extends StatelessWidget {
  const AppContent({super.key, required this.child, this.maxWidth = 920});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
