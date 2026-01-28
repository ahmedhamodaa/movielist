import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/presentation/views/home_view.dart';
import 'package:movielist/presentation/widgets/body/register/login_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TmdbService _tmdbService = TmdbService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 1));

    final isLoggedIn = await _tmdbService.isLoggedIn();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? HomeView() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icon/movielist.svg', width: 220),

            SizedBox(height: 44),

            CircularProgressIndicator(color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
