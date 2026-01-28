import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_styles.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.showArrow = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing; // غيّرها لـ nullable
  final bool showArrow; // ضف final
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: AppStyles.s16.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                trailing!,
                style: AppStyles.s14.copyWith(color: AppColors.lightGrey),
              ),
            ),
          if (showArrow) Icon(Icons.chevron_right, color: AppColors.lightGrey),
        ],
      ),
      onTap: onTap,
    );
  }
}
