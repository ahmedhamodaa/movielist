import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/presentation/widgets/app_bar/custom_search_bar.dart';
import 'package:movielist/presentation/widgets/body/search/custom_search_bar.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar({
    super.key,
    this.snap = false,
    this.floating = false,
    this.pinned = false,
    this.title,
    this.actions,
    this.height,
    this.bottom,
  });
  bool pinned;
  bool floating;
  bool snap;
  final double? height;
  final Widget? title;
  List<Widget>? actions;
  PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: AppColors.darkColor,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: height,
      backgroundColor: AppColors.darkColor,
      title: title,
      toolbarHeight: kToolbarHeight * 1.25,
      centerTitle: false,
      actionsPadding: EdgeInsets.only(right: 8),
      actions: actions,
      bottom: bottom,
    );
  }
}




      //   PreferredSize(
      //   preferredSize: Size.fromHeight(72),
      //   child: CustomSearchBar(),
      // ),
