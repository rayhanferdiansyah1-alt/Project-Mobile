import 'package:flutter/material.dart';

/// Kotak putih berlabel kapital untuk satu field di form unit.
class FieldBox extends StatelessWidget {
  const FieldBox({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

/// InputDecoration polos (tanpa garis) untuk field di dalam [FieldBox].
InputDecoration plainInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
    isDense: true,
    border: InputBorder.none,
  );
}
