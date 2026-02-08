import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StravaTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfile;
  final VoidCallback? onSearch;
  final VoidCallback? onInbox;
  final VoidCallback? onNotifications;

  const StravaTopBar({
    super.key,
    this.onProfile,
    this.onSearch,
    this.onInbox,
    this.onNotifications,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Movnos',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Color(0xFFE5E7EB),
          child: Icon(Icons.person, color: Colors.black87),
        ),
        onPressed: onProfile,
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: onSearch),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: onInbox,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: onNotifications,
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

class StravaSectionHeader extends StatelessWidget {
  final String title;
  final String? chip;
  final String? action;
  final VoidCallback? onAction;

  const StravaSectionHeader({
    super.key,
    required this.title,
    this.chip,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 18,
                color: AppTheme.stravaOrange,
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              if (chip != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    chip!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: AppTheme.stravaOrange,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class StravaCard extends StatelessWidget {
  final Widget child;
  const StravaCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}
