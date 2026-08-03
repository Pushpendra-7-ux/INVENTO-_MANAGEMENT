import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'touchable_scale.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final bool hasGradientBorder;
  final Color? glowColor;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.hasGradientBorder = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(hasGradientBorder ? 17.5 : 16);

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasGradientBorder ? Colors.transparent : AppColors.borderColor,
          width: 0.5,
        ),
      ),
      child: child,
    );

    if (hasGradientBorder) {
      cardContent = Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: borderRadius,
        ),
        child: cardContent,
      );
    }

    if (onTap != null || onLongPress != null) {
      return TouchableScale(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        glowColor: glowColor,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
