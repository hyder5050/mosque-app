import 'package:find_masjid/widget/custom/custon_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  
  bool isLoading = false;
  bool emailSent = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          emailSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Password reset email sent successfully!',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "";
      IconData icon = Icons.error_outline;
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address.';
          icon = Icons.person_off_outlined;
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          icon = Icons.email_outlined;
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          icon = Icons.timer_outlined;
          break;
        default:
          message = 'Failed to send reset email. Please try again.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('An unexpected error occurred.')),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.02),
                      // Back Button
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(height: height * 0.03),
                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            // Animated Icon with gradient container
                            Container(
                              width: width * 0.28,
                              height: width * 0.28,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: emailSent 
                                      ? [Colors.green.shade500, Colors.green.shade900]
                                      :[Colors.green.shade200, Colors.green.shade500],
                                      
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (emailSent ? Colors.green : Colors.blue)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                emailSent 
                                    ? Icons.mark_email_read_rounded
                                    : Icons.lock_reset_rounded,
                                size: width * 0.14,
                                color: Colors.white,
                              ),
                            ),
                            
                            SizedBox(height: height * 0.03),
                            
                            Text(
                              emailSent ? 'Check Your Email' : 'Forgot Password?',
                              style: TextStyle(
                                fontSize: width * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: height * 0.015),
                            
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                              child: Text(
                                emailSent
                                    ? 'We\'ve sent a password reset link to ${_emailController.text.trim()}'
                                    : 'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                                style: TextStyle(
                                  fontSize: width * 0.038,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: height * 0.05),
                      
                      // Show different content based on email sent status
                      if (!emailSent) ...[
                        // Email Field
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: _emailController,
                          labelText: '',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.green),
                          validator: _emailValidator,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        
                        SizedBox(height: height * 0.025),
                        
                        // Info Box
                        Container(
                          padding: EdgeInsets.all(width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: width * 0.05,
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: Text(
                                  'You will receive an email with instructions to reset your password.',
                                  style: TextStyle(
                                    fontSize: width * 0.032,
                                    color: Colors.blue.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: height * 0.04),
                        
                        // Reset Password Button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.07,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : resetPassword,
                            icon: isLoading
                                ? SizedBox.shrink()
                                : Icon(Icons.send_rounded, size: width * 0.05),
                            label: isLoading
                                ? SizedBox(
                                    width: width * 0.06,
                                    height: width * 0.06,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
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
                            ),
                          ),
                        ),
                      ] else ...[
                        // Email Sent Success View
                        Container(
                          padding: EdgeInsets.all(width * 0.08),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green.shade600,
                                size: width * 0.15,
                              ),
                              SizedBox(height: height * 0.02),
                              Text(
                                'Email Sent Successfully!',
                                style: TextStyle(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                'Please check your inbox and spam folder.',
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  color: Colors.green.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: height * 0.03),
                        
                        // Resend Email Button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.07,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : resetPassword,
                            icon: Icon(Icons.refresh_rounded, size: width * 0.05),
                            label: Text(
                              'Resend Email',
                              style: TextStyle(
                                fontSize: width * 0.04,
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
                      ],
                      
                      SizedBox(height: height * 0.03),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                        ],
                      ),
                      
                      SizedBox(height: height * 0.02),
                      
                      // Back to Login Button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.07,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            size: width * 0.05,
                          ),
                          label: Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: height * 0.03),
                      
                      // Help Section
                      Container(
                        padding: EdgeInsets.all(width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.grey[700],
                                  size: width * 0.05,
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  'Need Help?',
                                  style: TextStyle(
                                    fontSize: width * 0.038,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.015),
                            _HelpItem(
                              text: 'Check your spam or junk folder',
                              width: width,
                            ),
                            _HelpItem(
                              text: 'Make sure you entered the correct email',
                              width: width,
                            ),
                            _HelpItem(
                              text: 'Wait a few minutes for the email to arrive',
                              width: width,
                            ),
                            SizedBox(height: height * 0.01),
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(Icons.support_agent, color: Colors.green),
                                        SizedBox(width: 10),
                                        Text('Contact Support'),
                                      ],
                                    ),
                                    content: Text(
                                      'If you\'re still having trouble, please contact our support team at support@example.com',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.contact_support_outlined, size: width * 0.045),
                              label: Text(
                                'Contact Support',
                                style: TextStyle(fontSize: width * 0.035),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Help Item Widget
class _HelpItem extends StatelessWidget {
  final String text;
  final double width;

  const _HelpItem({
    required this.text,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: width * 0.04,
            color: Colors.green.shade600,
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: width * 0.032,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}