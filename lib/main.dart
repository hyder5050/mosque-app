import 'package:find_masjid/Superadmin/adminbottombar.dart';
import 'package:find_masjid/Superadmin/settings/userslist.dart';
import 'package:find_masjid/auth/forgot_page.dart';
import 'package:find_masjid/auth/login_page.dart';
import 'package:find_masjid/auth/signup_page.dart';
import 'package:find_masjid/screen/sattingsPages/updatepassword.dart';
import 'package:find_masjid/screen/importantScrrens/splach.dart';
import 'package:find_masjid/screen/sattingsPages/updateprofile.dart';
import 'package:find_masjid/screen/userapages/userbottombar.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,

      // ],
      // supportedLocales: const[
      //   Locale('en',''),
      //   Locale('ur',''),
      // ],
      // locale: const Locale('ur', ''),
      theme: ThemeData(
        useMaterial3: false,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),

      home: const LandingPage(),
      routes: {
        // Important Screens
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/update-profile': (context) => const EditProfileScreen(),


        // User Pages
        '/userhome': (context) => const Userbottombar(),
        
        // '/userprofile': (context) => const Settings(),
      
        // Superadmin Pages
        '/adminhome': (context) => const Admin_bottom_bar(),

        // Settings Pages for Superadmin
        // '/adminProfile': (context) => const adminProfile(),
        '/allusers': (context) => const AdminUserManagement(),
      },
    );
  }
}
