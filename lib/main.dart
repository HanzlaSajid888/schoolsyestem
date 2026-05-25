import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_layout.dart';
import 'screens/auth/login_screen.dart';
import 'core/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('auth_token');
  
  runApp(EduStreamApp(isLoggedIn: isLoggedIn));
}

class EduStreamApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const EduStreamApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduStream SMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: isLoggedIn ? const MainLayout() : const LoginScreen(),
    );
  }
}
