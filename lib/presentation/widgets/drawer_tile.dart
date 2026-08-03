import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'gradient_text.dart';
import 'touchable_scale.dart';

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  const DrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TouchableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        glowColor: AppColors.gradient1,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gradient1.withValues(alpha: 0.15) : AppColors.cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gradient1 : AppColors.borderColor.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(
              icon,
              color: isSelected ? AppColors.gradient1 : AppColors.subtitleText,
            ),
            title: isSelected
                ? GradientText(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  )
                : Text(
                    label,
                    style: const TextStyle(color: AppColors.whiteColor, fontSize: 15),
                  ),
            trailing: badgeCount != null && badgeCount! > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.buttonGradient,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
