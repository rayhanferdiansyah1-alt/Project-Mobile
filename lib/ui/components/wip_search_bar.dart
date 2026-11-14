import 'package:flutter/material.dart';

/// Kolom pencarian mengambang di dashboard Service Advisor.
class WipSearchBar extends StatelessWidget {
  const WipSearchBar({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari No. WO atau tipe kendaraan',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
