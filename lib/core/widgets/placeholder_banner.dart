import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/sanctum_colors.dart';

/// Honest "coming soon" indicator for MVP placeholders.
class PlaceholderBanner extends StatelessWidget {
  const PlaceholderBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.sanctumPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.isDark ? p.surfaceElevated : SanctumLight.creamDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SanctumBrand.goldSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
