// import 'package:find_masjid/screen/verficiationScreeen.dart';
// import 'package:find_masjid/widget/custom/custon_textfield.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   // final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _cnicController = TextEditingController();
//   bool isloading = false;

//   Future<void> signup() async{
//     if (!_formKey.currentState!.validate())return;
//     setState(() {
//       isloading = true;
//     });
//     try {
//       UserCredential userCredential =
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//         );
//           User? user =FirebaseAuth.instance.currentUser;
//           if(user != null && !user.emailVerified){
//             await user.sendEmailVerification();
//           }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Account Created Successfully! Verification email sent."))
//         );
//         Navigator.pushReplacement(context,
//         MaterialPageRoute(builder: (_)=> VerifyEmailScreen())
//         );

//     }
//     catch (e){
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }
//     setState(() {
//       isloading = false;
//     });
//   }

//   String? _emailValidator(String? value){
//     if (value == null || !value.contains('@')) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   }

//   String? _passwordValidator(String? value){
//     if (value == null || value.length < 6) {
//       return 'Password must be at least 6 characters long';
//     }
//     return null;
//   }
//   String? _confirmPasswordValidator(String? value){
//     if (value != _passwordController.text) {
//       return 'Passwords do not match';
//     }
//     return null;
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _cnicController.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CustomTextField(controller: _emailController,
//                     labelText: 'Email',
//                     hintText: "Enter your Email",
//                     prefixIcon: Icon(Icons.email,
//                     color: Colors.green,
//                     ),
//                     validator: _emailValidator,
//                     keyboardType: TextInputType.emailAddress,
//                     ),
//                      const SizedBox(height: 10.0),
//                      CustomTextField(controller: _cnicController,
//                      labelText: 'CNIC (Optional)',
//                         hintText: 'Enter your CNIC',
//                         prefixIcon: Icon(Icons.credit_card,
//                         color: Colors.green,),
//                         keyboardType: TextInputType.number,
//                     ),

//                     const SizedBox(height: 10.0),
//                     CustomTextField(controller: _passwordController,
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     prefixIcon: Icon(Icons.lock,
//                     color: Colors.green,),
//                     obscureText: true,
//                     validator: _passwordValidator,
//                     ),

//                     const SizedBox(height: 10.0),
//                     CustomTextField(controller: _confirmPasswordController,
//                      labelText: 'Confirm Password',
//                         hintText: 'Re-enter your password',
//                         prefixIcon: Icon(Icons.lock,
//                         color: Colors.green,),
//                           obscureText: true,
//                       validator: _confirmPasswordValidator,
//                      ),

//                     const SizedBox(height: 10.0),
//                      GestureDetector(
//                       onTap: isloading ? null :signup,

//                       child: Container(
//                         height: 50,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: Colors.green,
//                         ),
//                         child: Center(
//                           child: isloading
//                           ? CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           )
//                           : Text('Signup',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold
//                           ),)),
//                       ),
//                     ),
//                     TextButton(onPressed: (){
//                       Navigator.of(context).pushNamed('/login');
//                     }, child: const Text('Already have an account? Login'))
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     }
// }

import 'package:find_masjid/screen/importantScrrens/verficiationScreeen.dart';
import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:find_masjid/widget/custom/custon_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

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

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  Future<void> signup()
  // (dynamic _nameController)
  async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Please agree to the Terms and Conditions')),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': userCredential.user!.email,
            'name': _usernameController.text,
            'uid': userCredential.user!.uid,
            'isBlocked': false,
          });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Account created successfully! Verification email sent.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );

        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "";
      IconData icon = Icons.error_outline;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please login instead.';
          icon = Icons.person_outline;
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          icon = Icons.email_outlined;
          break;
        case 'weak-password':
          message = 'Password is too weak. Use a stronger password.';
          icon = Icons.lock_outline;
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          icon = Icons.block;
          break;
        default:
          message = 'Signup failed: ${e.message}';
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
                Expanded(
                  child: Text('An unexpected error occurred: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _cnicValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length != 13) {
        return 'CNIC must be 13 digits';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'CNIC must contain only numbers';
      }
    }
    return null;
  }

  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long.';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cnicController.dispose();
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
                      SizedBox(height: height * 0.04),

                      // Back Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey[800],
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),

                      SizedBox(height: height * 0.02),

                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: width * 0.2,
                              height: width * 0.2,
                              decoration: BoxDecoration(
                                gradient: AppColor.primaryGradient,
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
                                Icons.person_add_rounded,
                                size: width * 0.1,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: width * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              'Sign up to get started',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.04),

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
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColor.primary,
                        ),
                        validator: _emailValidator,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: height * 0.02),

                      // Name field
                      Text(
                        'Full name',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      CustomTextField(
                        controller: _usernameController,
                        labelText: '',
                        hintText: 'Enter your name',
                        prefixIcon: Icon(
                          Icons.person_2_outlined,
                          color: AppColor.primary,
                        ),
                        validator: _nameValidator,
                      ),
                      SizedBox(height: height * 0.02),

                      // CNIC Field (Optional)
                      Text(
                        'CNIC (Optional)',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      CustomTextField(
                        controller: _cnicController,
                        labelText: '',
                        hintText: 'Enter your 13-digit CNIC',
                        prefixIcon: Icon(
                          Icons.credit_card_outlined,
                          color: AppColor.primary,
                        ),
                        keyboardType: TextInputType.number,
                        validator: _cnicValidator,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                      ),

                      SizedBox(height: height * 0.02),

                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: '',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColor.primary,
                        ),
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: _passwordValidator,
                      ),

                      // Password strength indicator
                      // SizedBox(height: height * 0.01),
                      // _buildPasswordStrengthIndicator(),
                      SizedBox(height: height * 0.02),

                      // Confirm Password Field
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: '',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColor.primary,
                        ),
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: _confirmPasswordValidator,
                      ),

                      SizedBox(height: height * 0.02),

                      // Terms and Conditions Checkbox
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.02,
                          vertical: height * 0.01,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreeToTerms = !_agreeToTerms;
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * 0.032,
                                      color: Colors.grey[800],
                                    ),
                                    children: [
                                      TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await signup();
                                },
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
                          child: isLoading
                              ? SizedBox(
                                  width: width * 0.06,
                                  height: width * 0.06,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: height * 0.025),

                      // Divider with "OR"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                            ),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.03,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.025),

                      // Login Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: width * 0.035,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/login');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.035,
                                ),
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

  //   Widget _buildPasswordStrengthIndicator() {
  //     final password = _passwordController.text;
  //     int strength = 0;
  //     String strengthText = '';
  //     Color strengthColor = Colors.grey;

  //     if (password.isEmpty) {
  //       return SizedBox.shrink();
  //     }

  //     if (password.length >= 6) strength++;
  //     if (password.length >= 8) strength++;
  //     if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
  //     if (RegExp(r'[0-9]').hasMatch(password)) strength++;
  //     if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

  //     if (strength <= 2) {
  //       strengthText = 'Weak';
  //       strengthColor = Colors.red;
  //     } else if (strength <= 3) {
  //       strengthText = 'Medium';
  //       strengthColor = Colors.orange;
  //     } else {
  //       strengthText = 'Strong';
  //       strengthColor = AppColor.primary;
  //     }

  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: LinearProgressIndicator(
  //                 value: strength / 5,
  //                 backgroundColor: Colors.grey[200],
  //                 color: strengthColor,
  //                 minHeight: 4,
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             SizedBox(width: 10),
  //             Text(
  //               strengthText,
  //               style: TextStyle(
  //                 color: strengthColor,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 6),
  //         Text(
  //           'Use uppercase, numbers, and symbols for a stronger password',
  //           style: TextStyle(
  //             fontSize: 11,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     );
  //   }
}
