import 'package:flutter/material.dart';

import '../app_user_menu.dart';
import 'curved_header.dart';

/// Header dashboard Service Advisor.
class SaHeader extends StatelessWidget {
  const SaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CurvedHeader(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 48),
      curveDepth: 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoleBadge('SERVICE ADVISOR'),
              AppUserMenu(),
            ],
          ),
          const SizedBox(height: 18),
          const HeaderTitle('Data Unit WIP'),
          const SizedBox(height: 4),
          Text(
            'Kelola data unit kendaraan masuk bengkel',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
