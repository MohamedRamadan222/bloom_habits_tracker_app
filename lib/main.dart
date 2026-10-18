import 'package:flutter/material.dart';
import 'features/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        fontFamily: 'Manrope',
      ),
      debugShowCheckedModeBanner: false,
      title: 'bloom habit tracker',
      home: MainLayout(),
    );
  }
}
