// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mcqs_entry/common/utills/session_box.dart';
import 'package:mcqs_entry/global.dart';
import 'package:mcqs_entry/pages/data_entry/data_entry_page.dart';
import 'package:mcqs_entry/pages/data_entry/provider.dart';
import 'package:mcqs_entry/pages/login/login_page.dart';
import 'package:provider/provider.dart';

void main() async {
  await Global.init();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DataEntryProvider())],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) {
        return const MaterialApp(
            debugShowCheckedModeBanner: false, home: HomePage());
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<bool> _checkSession() async {
    final storedToken = await SessionBox.getToken();
    return storedToken != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking the session
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors that occurred during session check
            return Center(child: Text('Error occurred: ${snapshot.error}'));
          } else {
            final bool isLoggedIn = snapshot.data ?? false;
            if (isLoggedIn) {
              // User is logged in, show the next page
              return const DataEntryPage();
            } else {
              // User is not logged in, show the login page
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}
