// import 'package:find_masjid/widget/custom/custon_textfield.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool isloading =false;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
  

//   Future<void> login() async{
//     if (!_formKey.currentState!.validate())return;
//     setState(() {
//       isloading = true;
//     });
//     try{
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim()
//         );
//         Navigator.of(context).pushReplacementNamed( '/home');
//     } on FirebaseAuthException catch(e) {
//       String message = "";
//       switch (e.code){
//         case 'user-not-found':
//         message = 'No user found with this email. Please sign up first.';
//         break;
//         case 'wrong-password':
//         message = 'Invalid password. Please try again.';
//         break;
//         case 'invalid-email':
//         message = 'Invalid email format.';
//         break;
//         default:
//         message = 'Login failed. Please try again.';

//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message))
//       );
//     }
//     catch (e){
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An unexpected error occurred.'))
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
  

//   @override

//   void dispose(){
//     _emailController.dispose();
//     _passwordController.dispose();
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
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10,right: 10),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 300,),
//                       CustomTextField(controller: _emailController,
//                       labelText: 'Email',
//                       hintText: 'Enter your email',
//                       prefixIcon: Icon(Icons.email, 
//                           color: Colors.green,),
//                       validator: _emailValidator,
//                       ),
//                       SizedBox(height: 10,),
//                       CustomTextField(controller: _passwordController,
//                       labelText: "Password",
//                       hintText: 'Enter your password',
//                       prefixIcon: Icon(Icons.lock, 
//                           color: Colors.green,),
//                           obscureText: true,
//                       validator: _passwordValidator,
//                       ),
                    
                   
//                       const SizedBox(height: 10.0),
//                       GestureDetector(
//                         onTap: isloading ? null :login,
                        
//                         child: Container(
//                           height: 50,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.green,
//                           ),
//                           child: Center(
//                             child: isloading
//                             ? const CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             )
//                             : Text('Login',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold
//                             ),)),
//                         ),
//                       ),
                    
//                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           TextButton(onPressed: (){
//                             Navigator.of(context).pushNamed('/signup');
//                           }, child: const Text('Registration',
//                           style: TextStyle(decoration: TextDecoration.underline
//                           ,color: Colors.green),)),
//                           TextButton(onPressed: (){
//                             Navigator.of(context).pushNamed('/signup');
//                           }, child: const Text('ForgetPassword',
//                           style: TextStyle(decoration: TextDecoration.underline
//                           ,color: Colors.green),)),
                          
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:find_masjid/widget/custom/custon_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  // String adminEmail = "admin@gmail.com"; 

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
  
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    print('Attempting login for user: ${_emailController.text.trim()}');
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print("Login successful for user: ${userCredential.user?.email}");
      if(_emailController.text.trim() =='admin1@example.com' 
      && _passwordController.text.trim() =='admin123'){
        Navigator.of(context).pushReplacementNamed('/adminhome');
        return;
        // print("login as admin");
        } else {
          Navigator.of(context).pushReplacementNamed('/userhome');
          print("login as user");
        }
         
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Login successful!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 2),
          ),
        );
        print("Navigating to home page...");
        
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.of(context).pushReplacementNamed('/home');
      } print('Navigation to home page initiated.');
    } on FirebaseAuthException catch (e) {
      String message = "";
      IconData icon = Icons.error_outline;
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email. Please sign up first.';
          icon = Icons.person_off_outlined;
          break;
        case 'wrong-password':
          message = 'Invalid password. Please try again.';
          icon = Icons.lock_outline;
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          icon = Icons.email_outlined;
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          icon = Icons.block;
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          icon = Icons.timer_outlined;
          break;
        default:
          message = 'Login failed. Please try again.';
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

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      // Logo/Brand Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppColor.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.mosque_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sign in to continue',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 50),
                      
                      // Email Field
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      CustomTextField(
                        controller: _emailController,
                        labelText: '',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email_outlined, color: AppColor.primary),
                        validator: _emailValidator,
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: '',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColor.primary),
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                      
                      SizedBox(height: 12),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/forgot-password');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null :  () async {
                            await login();
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
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Divider with "OR"
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Social Login Buttons (Optional)
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _SocialLoginButton(
                      //         icon: Icons.g_mobiledata_rounded,
                      //         label: 'Google',
                      //         onPressed: () {
                      //           // Implement Google Sign-In
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             SnackBar(
                      //               content: Text('Google Sign-In coming soon'),
                      //               behavior: SnackBarBehavior.floating,
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //     SizedBox(width: 16),
                      //     Expanded(
                      //       child: _SocialLoginButton(
                      //         icon: Icons.apple_rounded,
                      //         label: 'Apple',
                      //         onPressed: () {
                      //           // Implement Apple Sign-In
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             SnackBar(
                      //               content: Text('Apple Sign-In coming soon'),
                      //               behavior: SnackBarBehavior.floating,
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      
                      // SizedBox(height: 32),
                      
                      // Sign Up Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/signup');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30),
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

// Social Login Button Widget
// class _SocialLoginButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onPressed;

//   const _SocialLoginButton({
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 24),
//       label: Text(
//         label,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: Colors.grey[800],
//         side: BorderSide(color: Colors.grey[300]!, width: 1.5),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: EdgeInsets.symmetric(vertical: 14),
//       ),
//     );
//   }
// }