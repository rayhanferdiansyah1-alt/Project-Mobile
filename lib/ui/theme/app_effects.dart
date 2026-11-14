import 'package:flutter/material.dart';

/// Gradien header gelap yang dipakai semua dashboard dan form.
class AppGradients {
  AppGradients._();

  static LinearGradient header(Color primary) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(primary, Colors.black, 0.1)!,
          Color.lerp(primary, Colors.black, 0.4)!,
        ],
      );
}

/// Bayangan kartu dan pill yang berulang di banyak layar.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get pill => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
