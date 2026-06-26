import 'package:flutter/material.dart';
import 'package:zana_calorie/features/auth/ui/login/login.dart';
import 'package:zana_calorie/theme/light_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zana caloire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 18,
            fontFamily: "Vazir",
            color: AppColors.text,
          ),
          bodySmall: TextStyle(
            fontFamily: "Vazir",
            color: AppColors.text,
          )
        ),
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}

