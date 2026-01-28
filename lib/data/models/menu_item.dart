import 'package:flutter/material.dart';

// Menu Item Model
class MenuItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool showArrow;

  MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.showArrow = true,
  });
}
