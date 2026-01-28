import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_styles.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    this.onTap,
    this.title,
    this.subTitle,
    this.leading,
    this.onPressed,
  });

  final void Function()? onTap;
  final Widget? title;
  final Widget? subTitle;
  final Widget? leading;
  final Future<void> Function()? onPressed; // Changed to async

  @override
  Widget build(BuildContext context) {
    // Check if this is the Favorites item
    final isFavorites = title is Text && (title as Text).data == 'Favorites';

    return isFavorites
        ? ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: onTap,
            title: title,
            titleTextStyle: AppStyles.s16,
            subtitleTextStyle: AppStyles.s14,
            subtitle: subTitle,
            leading: leading,
          )
        : Slidable(
            key: const ValueKey(0),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: onPressed != null
                      ? (context) async {
                          await onPressed!();
                        }
                      : null,
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: onTap,
              title: title,
              titleTextStyle: AppStyles.s16,
              subtitleTextStyle: AppStyles.s14,
              subtitle: subTitle,
              leading: leading,
            ),
          );
  }
}
