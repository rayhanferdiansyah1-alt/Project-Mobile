import 'package:flutter/material.dart';

import 'curved_header.dart';

/// Header form tambah / edit unit (Service Advisor).
class FormHeader extends StatelessWidget {
  const FormHeader({super.key, required this.isEditMode});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return CurvedHeader(
      padding: const EdgeInsets.fromLTRB(16, 56, 20, 40),
      curveDepth: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const RoleBadge('SERVICE ADVISOR'),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: HeaderTitle(
              isEditMode ? 'Edit Unit WIP' : 'Tambah Unit WIP',
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
