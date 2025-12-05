// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {

//   bool isSending = false;
//   Timer? timer;
//   @override
//   void initState() {
//     super.initState();
//     timer = Timer.periodic(Duration(seconds: 3),(_) => checkVerification());
//   }

//   Future<void> checkVerification() async {
//     await FirebaseAuth.instance.currentUser!.reload();
//     final user =FirebaseAuth.instance.currentUser;
//     if(user != null && user.emailVerified){
//       timer?.cancel();
//       Navigator.pushReplacementNamed(context, '/home');
//     }
    
//   }
//   @override
//   void dispose(){
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.email, size: 80, color: Colors.green),
//               SizedBox(height: 20),

//               Text(
//                 "Please verify your email",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 10),

//               Text(
//                 "A verification link has been sent to your email.",
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 40),

//               ElevatedButton(
//                 onPressed: () async {
//                   setState(() => isSending = true);
//                   await FirebaseAuth.instance.currentUser!.sendEmailVerification();
//                   setState(() => isSending = false);
//                 },
//                 child: isSending
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text("Resend Email"),
//               ),

//               SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: () async {
//                   checkVerification();
//                 },
//                 child: Text("I have verified"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> with SingleTickerProviderStateMixin {
  bool isSending = false;
  bool canResend = true;
  int resendTimer = 60;
  Timer? timer;
  Timer? resendCountdown;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    
    // Check verification periodically
    timer = Timer.periodic(Duration(seconds: 3), (_) => checkVerification());
    
    // Send initial verification email
    sendVerificationEmail();
  }

  Future<void> checkVerification() async {
    try {
      await FirebaseAuth.instance.currentUser!.reload();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && user.emailVerified) {
        timer?.cancel();
        resendCountdown?.cancel();
        
        // Show success message before navigating
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Email verified successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error checking verification: $e');
    }
  }

  Future<void> sendVerificationEmail() async {
    if (!canResend) return;
    
    setState(() {
      isSending = true;
      canResend = false;
      resendTimer = 60;
    });

    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Verification email sent!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // Start countdown timer
      resendCountdown = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (resendTimer > 0) {
            resendTimer--;
          } else {
            canResend = true;
            timer.cancel();
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => canResend = true);
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    resendCountdown?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Email Icon with gradient container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // Title
                  Text(
                    "Verify Your Email",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16),

                  // Email display
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Description
                  Text(
                    "We've sent a verification link to your email address. Please check your inbox and click the link to verify your account.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16),

                  // Additional info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Don't forget to check your spam folder if you can't find the email.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Resend Email Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: canResend && !isSending
                          ? sendVerificationEmail
                          : null,
                      icon: isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.refresh_rounded, size: 22),
                      label: Text(
                        isSending
                            ? "Sending..."
                            : canResend
                                ? "Resend Verification Email"
                                : "Resend in ${resendTimer}s",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.green.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Check Verification Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: checkVerification,
                      icon: Icon(Icons.check_circle_outline_rounded, size: 22),
                      label: Text(
                        "I've Verified My Email",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade300, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Help text
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.help_outline, color: Colors.green),
                              SizedBox(width: 10),
                              Text('Need Help?'),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('If you haven\'t received the email:'),
                              SizedBox(height: 10),
                              Text('• Check your spam/junk folder'),
                              Text('• Verify your email address is correct'),
                              Text('• Wait a few minutes and try resending'),
                              Text('• Contact support if issues persist'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Got it'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.help_outline, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Having trouble?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Auto-checking indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade600,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Auto-checking verification status...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}