import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_extensions.dart';
import 'package:movielist/core/utils/app_styles.dart';

class MovieCard extends StatelessWidget {
  final String? name;
  final String? type;
  final String? date;
  final String? imageUrl;

  const MovieCard({
    super.key,
    this.name,
    this.type,
    this.date = '2000',
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final width = context.width;
    final scaleFactor = (width / 400).clamp(0.7, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Movie Poster
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 220,
            width: 200,
            color: AppColors.green,
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.movie, color: Colors.white),
                      );
                    },
                  )
                : Image.asset('assets/test.jpg', fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 8 * scaleFactor),

        // Movie Name
        Text(
          name ?? 'Movie Name',
          style: AppStyles.s16.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4 * scaleFactor),

        // Type and Date Row
        Row(
          children: [
            Flexible(
              child: Row(
                spacing: 4,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.movie,
                    size: 12 * scaleFactor,
                    color: AppColors.darkGery,
                  ),
                  Text(
                    type ?? 'Type',
                    style: AppStyles.s12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (date != null) ...[
              SizedBox(width: 4 * scaleFactor),
              Text(
                '·',
                style: TextStyle(
                  color: AppColors.darkGery,
                  fontWeight: FontWeight.w500,
                  fontSize: 12 * scaleFactor,
                ),
              ),
              SizedBox(width: 4 * scaleFactor),
              Flexible(
                child: Text(
                  date!,
                  style: AppStyles.s12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
