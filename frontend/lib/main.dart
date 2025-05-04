import 'package:flutter/material.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      debugShowCheckedModeBanner: false,
 
  //  home :TripDetailsPage(),
    home : MainScreen(),
  //    home : SearchFilterPage(),
  //  home : CreationVoyagePage(),
    );
  }
}
