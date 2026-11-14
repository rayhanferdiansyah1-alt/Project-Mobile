import 'package:flutter/material.dart';

import '../app_user_menu.dart';
import 'curved_header.dart';

/// Header dashboard Partman / Staf Asuransi.
class PartmanHeader extends StatelessWidget {
  const PartmanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CurvedHeader(
      padding: EdgeInsets.fromLTRB(20, 56, 20, 46),
      curveDepth: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoleBadge('PARTMAN / STAF ASURANSI'),
              AppUserMenu(),
            ],
          ),
          SizedBox(height: 18),
          HeaderTitle('Status Unit WIP'),
        ],
      ),
    );
  }
}
