import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.height,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.fontColor = Colors.white,
    this.borderColor,
    this.onPressed,
    this.width,
    this.shape,
  });

  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final Color? fontColor;
  final double? height;
  final IconData? icon;
  final String label;
  final double? width;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48,
      width: width,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: shape,
          side: borderColor == null
              ? null
              : BorderSide(color: borderColor!, width: 2),
          backgroundColor: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AutoSizeText(
                label,
                style: TextStyle(
                  color: fontColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                minFontSize: 8,
                maxLines: 1,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 5),
              Icon(icon, size: 18, color: iconColor),
            ],
          ],
        ),
      ),
    );
  }
}
