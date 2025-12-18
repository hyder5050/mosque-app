import 'package:flutter/material.dart';

// Option Tile Widget for Bottom Sheet
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double width;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.01,
      ),
      leading: Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: width * 0.06),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: width * 0.032, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey[400],
        size: width * 0.06,
      ),
    );
  }
}