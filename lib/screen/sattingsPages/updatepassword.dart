import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:find_masjid/widget/custom/custon_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool passwordChanged = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Listen to password changes for strength indicator
    _newPasswordController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      if (user == null || email == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User not found');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      if (mounted) {
        setState(() {
          passwordChanged = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Password changed successfully!',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "";
      IconData icon = Icons.error_outline;

      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect.';
          icon = Icons.lock_outline;
          break;
        case 'weak-password':
          message = 'New password is too weak. Please choose a stronger password.';
          icon = Icons.security_outlined;
          break;
        case 'requires-recent-login':
          message = 'Please log out and log in again before changing your password.';
          icon = Icons.login_outlined;
          break;
        case 'user-not-found':
          message = 'User not found. Please log in again.';
          icon = Icons.person_off_outlined;
          break;
        default:
          message = 'Failed to change password: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('An unexpected error occurred: ${e.toString()}')),
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

  String? _currentPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value == _currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                        constraints: const BoxConstraints(),
                      ),

                      SizedBox(height: height * 0.03),

                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: width * 0.25,
                              height: width * 0.25,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: passwordChanged
                                      ? [Colors.green.shade100, Colors.green.shade500]
                                      : [Colors.green.shade500, Colors.green.shade900],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (passwordChanged ? AppColor.secondary : AppColor.primary)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                passwordChanged
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.lock_reset_rounded,
                                size: width * 0.12,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: height * 0.025),

                            Text(
                              passwordChanged ? 'Password Changed!' : 'Change Password',
                              style: TextStyle(
                                fontSize: width * 0.07,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                                letterSpacing: -0.5,
                              ),
                            ),

                            SizedBox(height: height * 0.01),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                              child: Text(
                                passwordChanged
                                    ? 'Your password has been updated successfully.'
                                    : 'Create a new, strong password that you don\'t use for other websites.',
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      // Show form or success message
                      if (!passwordChanged) ...[
                        // Current Password Field
                        Text(
                          'Current Password',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: _currentPasswordController,
                          labelText: '',
                          hintText: 'Enter your current password',
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.green),
                          obscureText: _obscureCurrentPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                          validator: _currentPasswordValidator,
                        ),

                        SizedBox(height: height * 0.025),

                        // New Password Field
                        Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: _newPasswordController,
                          labelText: '',
                          hintText: 'Enter your new password',
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.green),
                          obscureText: _obscureNewPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          validator: _newPasswordValidator,
                        ),

                        // Password Strength Indicator
                        SizedBox(height: height * 0.015),
                        _buildPasswordStrengthIndicator(width),

                        SizedBox(height: height * 0.025),

                        // Confirm New Password Field
                        Text(
                          'Confirm New Password',
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
                          hintText: 'Re-enter your new password',
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.green),
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
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: _confirmPasswordValidator,
                        ),

                        SizedBox(height: height * 0.025),

                        // Password Requirements Info
                        _buildPasswordRequirements(width, height),

                        SizedBox(height: height * 0.035),

                        // Change Password Button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.07,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _changePassword,
                            icon: isLoading
                                ? const SizedBox.shrink()
                                : Icon(Icons.security_rounded, size: width * 0.05),
                            label: isLoading
                                ? SizedBox(
                                    width: width * 0.06,
                                    height: width * 0.06,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Update Password',
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
                        // Success State
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(width * 0.06),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Colors.green.shade600,
                                size: width * 0.15,
                              ),
                              SizedBox(height: height * 0.02),
                              Text(
                                'Password Updated Successfully!',
                                style: TextStyle(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                'Your account is now secured with your new password.',
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

                        // Back to Settings Button
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.07,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_rounded, size: width * 0.05),
                            label: Text(
                              'Back to Settings',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: height * 0.03),

                      // Cancel Button (only when form is visible)
                      if (!passwordChanged)
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.06,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: height * 0.02),

                      // Security Tips
                      if (!passwordChanged) _buildSecurityTips(width, height),

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

  // Password Strength Indicator Widget
  Widget _buildPasswordStrengthIndicator(double width) {
    final password = _newPasswordController.text;
    int strength = 0;
    String strengthText = '';
    Color strengthColor = Colors.grey;

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (strength <= 2) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength <= 3) {
      strengthText = 'Medium';
      strengthColor = Colors.orange;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength / 5,
                  backgroundColor: Colors.grey[200],
                  color: strengthColor,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: strengthColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                strengthText,
                style: TextStyle(
                  color: strengthColor,
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Password Requirements Widget
  Widget _buildPasswordRequirements(double width, double height) {
    final password = _newPasswordController.text;

    final requirements = [
      _PasswordRequirement(
        text: 'At least 6 characters',
        isMet: password.length >= 6,
      ),
      // _PasswordRequirement(
      //   text: 'One uppercase letter (A-Z)',
      //   isMet: RegExp(r'[A-Z]').hasMatch(password),
      // ),
      _PasswordRequirement(
        text: 'One number (0-9)',
        isMet: RegExp(r'[0-9]').hasMatch(password),
      ),
      // _PasswordRequirement(
      //   text: 'One special character (!@#\$%^&*)',
      //   isMet: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      // ),
    ];

    return Container(
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
                Icons.info_outline,
                color: Colors.grey[700],
                size: width * 0.045,
              ),
              SizedBox(width: width * 0.02),
              Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.015),
          ...requirements.map((req) => Padding(
                padding: EdgeInsets.only(bottom: height * 0.008),
                child: Row(
                  children: [
                    Icon(
                      req.isMet ? Icons.check_circle : Icons.circle_outlined,
                      color: req.isMet ? Colors.green : Colors.grey[400],
                      size: width * 0.045,
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: Text(
                        req.text,
                        style: TextStyle(
                          fontSize: width * 0.032,
                          color: req.isMet ? Colors.green.shade700 : Colors.grey[600],
                          fontWeight: req.isMet ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Security Tips Widget
  Widget _buildSecurityTips(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.blue.shade700,
                size: width * 0.05,
              ),
              SizedBox(width: width * 0.02),
              Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.015),
          _SecurityTipItem(
            text: 'Use a unique password for each account',
            width: width,
          ),
          _SecurityTipItem(
            text: 'Avoid using personal information',
            width: width,
          ),
          _SecurityTipItem(
            text: 'Consider using a password manager',
            width: width,
          ),
          _SecurityTipItem(
            text: 'Enable two-factor authentication if available',
            width: width,
          ),
        ],
      ),
    );
  }
}

// Password Requirement Model
class _PasswordRequirement {
  final String text;
  final bool isMet;

  _PasswordRequirement({
    required this.text,
    required this.isMet,
  });
}

// Security Tip Item Widget
class _SecurityTipItem extends StatelessWidget {
  final String text;
  final double width;

  const _SecurityTipItem({
    required this.text,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            size: width * 0.04,
            color: Colors.blue.shade600,
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: width * 0.032,
                color: Colors.blue.shade800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}