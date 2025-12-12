import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum BadgeType { verified, featured, purpose }

class BadgeWidget extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;
  
  const BadgeWidget({
    Key? key,
    required this.text,
    required this.type,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    Gradient? gradient;
    
    switch (type) {
      case BadgeType.verified:
        backgroundColor = AppColors.emeraldPrimary;
        break;
      case BadgeType.featured:
        backgroundColor = Colors.transparent;
        gradient = AppColors.featuredGradient;
        break;
      case BadgeType.purpose:
        backgroundColor = Colors.white.withOpacity(0.9);
        textColor = AppColors.slate900;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}