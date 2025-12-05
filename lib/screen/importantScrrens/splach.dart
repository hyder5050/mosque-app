import 'package:find_masjid/Superadmin/adminbottombar.dart';
import 'package:find_masjid/auth/login_page.dart';
import 'package:find_masjid/screen/userapages/userbottombar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null && user.email == 'admin@example.com') {
            return const Admin_bottom_bar(); // Already logged in as admin
          }
          else if (user != null) {
            return const Userbottombar();} // Already logged in as regular user  
           else {
            return const LoginPage(); // Not logged in
          }
        }

        // Loading screen while initializing Firebase
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

