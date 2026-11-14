import 'package:flutter/material.dart';

import '../../theme/app_effects.dart';

/// Memotong bagian bawah widget jadi lengkungan. [depth] = kedalaman lengkung.
/// Menggantikan 6 clipper kembar yang dulu tersebar di tiap layar
/// (bedanya hanya angka 24 / 30 / 32 / 36 / 60).
class CurveClipper extends CustomClipper<Path> {
  const CurveClipper(this.depth);

  final double depth;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - depth);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - depth);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) =>
      oldClipper is CurveClipper && oldClipper.depth != depth;
}

/// Kerangka header gelap bergradien dengan bawah melengkung.
class CurvedHeader extends StatelessWidget {
  const CurvedHeader({
    super.key,
    required this.padding,
    required this.curveDepth,
    required this.child,
  });

  final EdgeInsets padding;
  final double curveDepth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ClipPath(
      clipper: CurveClipper(curveDepth),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(gradient: AppGradients.header(primary)),
        child: child,
      ),
    );
  }
}

/// Pill transparan berisi nama role ("SERVICE ADVISOR", dst.).
/// Bawaan = gaya di header dashboard; [RoleBadge.hero] = gaya di halaman login.
class RoleBadge extends StatelessWidget {
  const RoleBadge(
    this.text, {
    super.key,
    this.horizontal = 12,
    this.vertical = 6,
    this.fillAlpha = 0.1,
    this.borderAlpha = 0.3,
    this.radius = 20,
    this.fontSize = 10.5,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 0.6,
  });

  const RoleBadge.hero(this.text, {super.key})
      : horizontal = 14,
        vertical = 7,
        fillAlpha = 0.08,
        borderAlpha = 0.35,
        radius = 24,
        fontSize = 10,
        fontWeight = FontWeight.w600,
        letterSpacing = 0.8;

  final String text;
  final double horizontal;
  final double vertical;
  final double fillAlpha;
  final double borderAlpha;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: fillAlpha),
        border: Border.all(color: Colors.white.withValues(alpha: borderAlpha)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

/// Judul besar putih di dalam header.
class HeaderTitle extends StatelessWidget {
  const HeaderTitle(this.text, {super.key, this.fontSize = 26});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}
