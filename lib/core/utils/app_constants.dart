// import 'package:portfolio/data/models/certificate.dart';
// import 'package:portfolio/presentation/widgets/body/projects/technology_text.dart';

// import '../../data/models/custom_service.dart';
// import '../../data/models/project.dart';
// import 'app_assets.dart';

// abstract class AppConstants {
//   static const double appBarHeight = 80;
//   static const List<CustomService> services = [
//     CustomService(
//       service: 'MOBILE DEVELOPMENT',
//       logo: AppAssets.androidLogo,
//       description:
//           'I am a Junior mobile developer. I have experience using Dart and Flutter Framework.',
//     ),
//     CustomService(
//       service: 'UI & UX DESIGNING',
//       logo: AppAssets.uiDesignLogo,
//       description:
//           'I design beautiful web interfaces with Figma and Adobe XD. I design beautiful web interfaces with Figma and Adobe XD.',
//     ),
//     CustomService(
//       service: 'WEB SCRAPING',
//       logo: AppAssets.scrappingLogo,
//       description:
//           'I can collect content and data from the internet then manipulate and analyze as needed.',
//     ),
//   ];
//   static const List<Project> projects = [
//     Project(
//       name: 'Notes App',
//       imageUrl: 'https://i.ibb.co/4wjNZvDH/NotesApp.png',
//       description:
//           'A Flutter notes application that allows users to create, edit, delete, and search notes with local storage using Hive database. Features include swipe-to-delete, note editing, search functionality, and a beautiful Material Design UI with custom animations.',
//       githubRepoLink: 'https://github.com/ahmedhamodaa/notes_app',
//       previewLink: '',
//       technologies: [
//         TechnologyText(text: 'Flutter'),
//         TechnologyText(text: 'Dart'),
//         TechnologyText(text: 'BLoC'),
//         TechnologyText(text: 'Hive'),
//         TechnologyText(text: 'Material Design'),
//       ],
//     ),

//     Project(
//       name: 'Store App',
//       imageUrl:
//           'https://i.ibb.co/v43NWdTf/PlusMart.png', // Add your project image URL here
//       description:
//           'An e-commerce Flutter application for browsing and managing products with features like product listing, category filtering, shopping cart, favorites, search functionality, and product management (CRUD operations). The app integrates with REST APIs to fetch, add, and update product information.',
//       githubRepoLink: '', // Add your GitHub repository link here
//       previewLink: '', // Add your preview/demo link here (YouTube, etc.)
//       technologies: [
//         TechnologyText(text: 'Flutter'),
//         TechnologyText(text: 'Dart'),
//         TechnologyText(text: 'REST API'),
//         TechnologyText(text: 'HTTP'),
//         TechnologyText(text: 'Material Design'),
//       ],
//     ),

//     Project(
//       name: 'Weather App',
//       imageUrl: 'https://i.ibb.co/Q3fyZtCv/Weather-App.png',
//       description:
//           'A weather application that allows users to search for any city and view current weather conditions, temperature, humidity, and forecast. Built with BLoC pattern for state management and integrates with Weather API for real-time data.',
//       githubRepoLink: 'https://github.com/ahmedhamodaa/weather_app',
//       previewLink: '',
//       technologies: [
//         TechnologyText(text: 'Flutter'),
//         TechnologyText(text: 'Dart'),
//         TechnologyText(text: 'BLoC'),
//         TechnologyText(text: 'Dio'),
//         TechnologyText(text: 'Weather API'),
//         TechnologyText(text: 'Material Design'),
//       ],
//     ),

//     Project(
//       name: 'NewsWave',
//       imageUrl: 'https://i.ibb.co/0RQtbVrK/NewsWave.png',
//       description:
//           'A modern news application built with Flutter that delivers real-time news across various categories, with a clean and intuitive user interface. Features categorized news browsing, search functionality, dark mode support, and responsive design.',
//       githubRepoLink: 'https://github.com/ahmedhamodaa/NewsWave',
//       previewLink: '',
//       technologies: [
//         TechnologyText(text: 'Flutter'),
//         TechnologyText(text: 'Dart'),
//         TechnologyText(text: 'BLoC'),
//         TechnologyText(text: 'Dio'),
//         TechnologyText(text: 'REST API'),
//         TechnologyText(text: 'Material Design'),
//       ],
//     ),
//   ];

//   static const List<Certificate> certificates = [
//     Certificate(
//       name: 'Flutter and Dart',
//       imageUrl: 'https://i.ibb.co/VYCWRgdy/Coursera-WS0-G1-U99-S3-K9.jpg',
//       description:
//           'Comprehensive course on cross-platform mobile development using Flutter and Dart. Covered widgets, state management, API integration, and building iOS/Android applications with modern UI/UX practices.',
//       date: '2025',
//       company: 'IBM',
//     ),
//     Certificate(
//       name: 'Mobile App Developer',
//       imageUrl: 'https://i.ibb.co/Jj1HS408/Certifi.jpg',
//       description:
//           'Professional certification in mobile application development for iOS and Android platforms.',
//       date: '2024-2025',
//       company: 'DEPI',
//     ),
//     Certificate(
//       name: 'Business English',
//       imageUrl: 'https://i.ibb.co/qYCFHCpN/Ahmed-Elsayed-Mostafa.jpg',
//       description:
//           'Completed Round 2 of Business English Track under Digital Egypt Pioneers Initiative (DEPI), focusing on professional English communication skills for the technology sector.',
//       date: '2025',
//       company: 'Berlitz Egypt',
//     ),
//     Certificate(
//       name: 'Complete Flutter & Dart Development',
//       imageUrl:
//           'https://i.ibb.co/DgC8X7c5/UC-2918b108-f69f-411f-8006-073a326fb99c.jpg',
//       description:
//           'Comprehensive 54-hour Flutter and Dart development course covering mobile app development fundamentals, widgets, state management, and building complete applications for iOS and Android.',
//       date: 'May 2025',
//       company: 'Udemy',
//     ),
//   ];
// }

import 'package:flutter/material.dart';
import 'package:movielist/data/models/menu_item.dart';

final List<MenuItem> menuItems = [
  MenuItem(icon: Icons.settings, title: 'Account Settings'),
  MenuItem(icon: Icons.notifications, title: 'Notifications', trailing: '3'),
  MenuItem(icon: Icons.security, title: 'Privacy & Security'),
  MenuItem(icon: Icons.help, title: 'Help & Support'),
  MenuItem(icon: Icons.info, title: 'About'),
  MenuItem(icon: Icons.logout, title: 'Logout', showArrow: false),
];
