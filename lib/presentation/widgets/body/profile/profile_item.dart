import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_styles.dart';
import 'package:movielist/data/models/models.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({super.key, this.accountDetails});

  final AccountDetails? accountDetails;

  String _getAvatarUrl() {
    if (accountDetails?.avatar?.tmdb?.avatarPath != null) {
      return 'https://image.tmdb.org/t/p/w200${accountDetails!.avatar!.tmdb!.avatarPath}';
    } else if (accountDetails?.avatar?.gravatar?.hash != null) {
      return 'https://www.gravatar.com/avatar/${accountDetails!.avatar!.gravatar!.hash}?s=200';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _getAvatarUrl();
    final username = accountDetails?.username ?? 'Guest User';
    final name = accountDetails?.name ?? '';

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        spacing: 20,
        children: [
          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, size: 50, color: AppColors.primaryColor)
                : null,
          ),
          // User Info
          Expanded(
            child: Column(
              spacing: 6,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name or Username
                AutoSizeText(
                  name.isNotEmpty ? name : username,
                  style: AppStyles.s18.copyWith(fontWeight: FontWeight.w600),
                  minFontSize: 10,
                  maxLines: 1,
                ),
                // Username (if name exists) or ID
                AutoSizeText(
                  name.isNotEmpty
                      ? '@$username'
                      : 'ID: ${accountDetails?.id ?? 'N/A'}',
                  style: AppStyles.s16.copyWith(color: AppColors.lightGrey),
                  minFontSize: 10,
                  maxLines: 1,
                ),
                // Additional info
                if (accountDetails != null)
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        size: 14,
                        color: AppColors.lightGrey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        accountDetails!.iso6391?.toUpperCase() ?? 'EN',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightGrey,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.lightGrey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        accountDetails!.iso31661 ?? 'US',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
