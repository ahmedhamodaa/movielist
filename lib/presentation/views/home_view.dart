import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/presentation/widgets/body/favorites/favorites_page.dart';
import 'package:movielist/presentation/widgets/body/home/home_page.dart';
import 'package:movielist/presentation/widgets/body/lists_screen.dart';
import 'package:movielist/presentation/widgets/body/search/search_page.dart';
import 'package:movielist/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:movielist/presentation/widgets/body/profile/profile_page.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentIndex = 0;

  late final PageController _pageController;

  final views = [HomePage(), SearchPage(), ListsScreen(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: views,
      ),
    );
  }
}
