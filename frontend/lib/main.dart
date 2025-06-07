import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';

// Global navigator key for accessing context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
 
  //  home :TripDetailsPage(),
    home : LoginScreen(),
  //    home : SearchFilterPage(),
  //  home : CreationVoyagePage(),
    );
  }
}
