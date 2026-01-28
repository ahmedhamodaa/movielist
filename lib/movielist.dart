import 'package:flutter/material.dart';
import 'package:movielist/presentation/views/home_view.dart';
import 'package:movielist/presentation/widgets/body/splash_screen.dart';
import 'config/theme_manager.dart';

class MovieList extends StatelessWidget {
  const MovieList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.darkTheme(),
      title: 'MovieList',
      home: SplashScreen(),
    );
  }
}
