import 'package:flutter/material.dart';
import 'package:shababi_quiz/Pages/CamScanner.dart';
import 'package:shababi_quiz/Pages/Teams.dart';
import 'package:shababi_quiz/Pages/gameScreen.dart';
import 'Pages/HomeScreen.dart';
import 'Pages/settings.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(Sizer(builder: (context, orientation, deviceType) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Shababi Quiz",
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        Settings.id: (context) => const Settings(),
        CamScanner.id: (context) => const CamScanner(),
        TeamsScreen.id: (context) => const TeamsScreen(),
        GameScreen.id: (context) => const GameScreen(),
      },
    );
  }));
}
