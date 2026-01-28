import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_extensions.dart';
import 'package:movielist/core/utils/app_styles.dart';
import 'package:movielist/presentation/widgets/body/home/movie_card.dart';

class MoviesSection extends StatelessWidget {
  final String title;
  final int itemCount;

  const MoviesSection({super.key, required this.title, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppStyles.s24),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(0),
                  overlayColor: Colors.transparent,
                ),
                onPressed: () {},
                child: Text(
                  "View All",
                  style: AppStyles.s16.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryColor,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 292, // Fixed height for horizontal ListView
          child: ListView.builder(
            itemExtent: 164,
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: const SizedBox(width: 120, child: MovieCard()),
              );
            },
          ),
        ),
      ],
    );
  }
}
