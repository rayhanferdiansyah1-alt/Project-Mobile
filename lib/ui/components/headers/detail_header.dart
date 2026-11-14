import 'package:flutter/material.dart';

import 'curved_header.dart';

/// Header halaman detail unit (Kepala Bengkel).
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.peringkat,
    required this.tipeKendaraan,
    required this.noWO,
  });

  final int peringkat;
  final String tipeKendaraan;
  final String noWO;

  @override
  Widget build(BuildContext context) {
    return CurvedHeader(
      padding: const EdgeInsets.fromLTRB(16, 52, 20, 36),
      curveDepth: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const CircleAvatar(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                radius: 16,
                child: Text('KB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'PERINGKAT $peringkat',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tipeKendaraan,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            noWO,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
