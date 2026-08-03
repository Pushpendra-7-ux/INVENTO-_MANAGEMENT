import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'touchable_scale.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final btnContent = Container(
      width: width,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isDisabled ? null : AppColors.buttonGradient,
        color: isDisabled ? AppColors.cardColor : null,
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.gradient1.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.whiteColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: isDisabled ? AppColors.subtitleText : AppColors.whiteColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: isDisabled ? AppColors.subtitleText : AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isDisabled) {
      return btnContent;
    }

    return TouchableScale(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      glowColor: AppColors.gradient1,
      child: btnContent,
    );
  }
}
