import 'package:flutter/material.dart';

import '../models/unit_wip.dart';
import 'app_theme.dart';

class UnitWipStreamView extends StatelessWidget {
  const UnitWipStreamView({
    super.key,
    required this.stream,
    required this.builder,
  });

  final Stream<List<UnitWip>> stream;
  final Widget Function(BuildContext context, List<UnitWip> units) builder;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<UnitWip>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
      }
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }
      return builder(context, snapshot.data!);
    },
  );
}
