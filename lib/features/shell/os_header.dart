import 'package:flutter/material.dart';

import '../../services/app_services.dart';

class OsHeader extends StatelessWidget implements PreferredSizeWidget {
  const OsHeader({
    super.key,
    required this.onMenuTap,
    required this.onFocusTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onFocusTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final os = AppServices.instance.osState;
    final focusTitle = os.activeFocus?.title ?? 'Set a Focus';

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuTap,
        tooltip: 'Menu',
      ),
      title: InkWell(
        onTap: onFocusTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  focusTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}
