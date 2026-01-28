// Add to pubspec.yaml:
// webview_flutter: ^4.4.2

import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.themoviedb.org/signup'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'), forceMaterialTransparency: true),
      body: WebViewWidget(controller: controller),
    );
  }
}
