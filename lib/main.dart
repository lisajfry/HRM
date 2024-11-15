import 'package:flutter/material.dart';
import 'package:hrm/screens/splash_screen.dart';
import 'package:hrm/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:hrm/model/TotalLembur.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TotalLemburProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HRM App',
        theme: lightMode,
        home: const SplashScreen(),
      ),
    );
  }
}
