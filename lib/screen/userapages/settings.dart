// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// class Settings extends StatelessWidget {
//   const Settings({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: const Text('Settings',
//           style: TextStyle(color: Colors.white),),
//         ),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: _mylistview(context),
//       ),
//     );
//   }
// }

// Widget _mylistview(BuildContext context) {
//   return ListView(
//     children:  <Widget>
//     [
//       ListTile(
//         leading: Icon(Icons.person,color: Colors.green,),
//         title: Text('Profile'),
//       ),
//       ListTile(
//         leading: Icon(Icons.language,color: Colors.green, ),
//         title: Text('Change Language'),
//       ),
//       ListTile(
//         leading: Icon(Icons.logout,color: Colors.green,),
//         title: Text('Logout'),
//         onTap: () async{
//           await FirebaseAuth.instance.signOut();
//           Navigator.pushReplacementNamed(context, '/login');
//         },
//       ),
//       ListTile(
//         leading: Icon(Icons.contact_emergency,color: Colors.green,  ),
//         title: Text('Contact Us'),
//       ),
//     ],
//   );
// }

// import 'package:find_masjid/screen/sattingsPages/updateprofile.dart';
import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedLanguage = 'English';
  
  String adminEmail = "admin@gmail.com";

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade600),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(child: Text('Failed to logout. Please try again.')),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Urdu', 'Arabic', 'Turkish'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.language_rounded, color: Colors.green.shade600),
            SizedBox(width: 10),
            Text('Select Language'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => RadioListTile<String>(
            title: Text(lang),
            value: lang,
            groupValue: selectedLanguage,
            activeColor: Colors.green.shade600,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to $value'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with gradient
            SliverAppBar(
              expandedHeight: height * 0.30,
              floating: false,
              pinned: true,
              backgroundColor: AppColor.secondary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Profile Avatar
                        Container(
                          width: width * 0.22,
                          height: width * 0.22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: width * 0.12,
                            color: AppColor.secondary,
                          ),
                        ),
                        // SizedBox(height: height * 0.015),
                        // Text(
                        //   user?.displayName ?? 'User',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: width * 0.05,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        SizedBox(height: height * 0.010),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: width * 0.035,
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                      ],
                    ),
                  ),
                ),
                
                
              ),bottom: PreferredSize(
                preferredSize:  Size.fromHeight(40),
                child:
         Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),)
                // centerTitle: true,
            ),

            // Settings Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),

                    // Account Section
                    _SectionHeader(
                      title: 'Account',
                      width: width,
                    ),
                    SizedBox(height: height * 0.015),
                    _SettingsCard(
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            iconColor: Colors.blue.shade600,
                            width: width,
                            onTap: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          _Divider(),
                          _SettingsTile(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            subtitle: user?.email ?? 'Not available',
                            iconColor: Colors.orange.shade600,
                            width: width,
                            trailing: Icon(
                              user?.emailVerified == true 
                                  ? Icons.verified_rounded 
                                  : Icons.warning_rounded,
                              color: user?.emailVerified == true 
                                  ? AppColor.primary 
                                  : Colors.orange,
                              size: width * 0.05,
                            ),
                          
                          ),
                          _Divider(),
                          _SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Change Password',
                            subtitle: 'Update your password',
                            iconColor: Colors.purple.shade600,
                            width: width,
                            onTap: () {
                              Navigator.pushNamed(context, '/mapStyle');
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Preferences Section
                    _SectionHeader(
                      title: 'Preferences',
                      width: width,
                    ),
                    SizedBox(height: height * 0.015),
                    _SettingsCard(
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: 'Manage notification preferences',
                            iconColor: Colors.red.shade600,
                            width: width,
                            trailing: Switch(
                              value: notificationsEnabled,
                              activeColor: Colors.green.shade600,
                              onChanged: (value) {
                                setState(() {
                                  notificationsEnabled = value;
                                });
                              },
                            ),
                          ),
                          _Divider(),
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: selectedLanguage,
                            iconColor: Colors.green.shade600,
                            width: width,
                            onTap: _showLanguageDialog,      
                          ),
                          _Divider(),

                          // _SettingsTile(
                          //   icon: Icons.dark_mode_outlined,
                          //   title: 'Dark Mode',
                          //   subtitle: 'Switch to dark theme',
                          //   iconColor: Colors.indigo.shade600,
                          //   width: width,
                          //   trailing: Switch(
                          //     value: darkModeEnabled,
                          //     activeColor: Colors.green.shade600,
                          //     onChanged: (value) {
                          //       setState(() {
                          //         darkModeEnabled = value;
                          //       });
                          //     },
                          //   ),
                          // ),
                          
                          
                        ],
                      ),
                    ),

                    // SizedBox(height: height * 0.03),

                    // // Support Section
                    // _SectionHeader(
                    //   title: 'Support',
                    //   width: width,
                    // ),
                    // SizedBox(height: height * 0.015),
                    // _SettingsCard(
                    //   child: Column(
                    //     children: [
                    //       _SettingsTile(
                    //         icon: Icons.help_outline_rounded,
                    //         title: 'Help Center',
                    //         subtitle: 'Get help and support',
                    //         iconColor: Colors.teal.shade600,
                    //         width: width,
                    //         onTap: () {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text('Opening Help Center...'),
                    //               behavior: SnackBarBehavior.floating,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       _Divider(),
                    //       _SettingsTile(
                    //         icon: Icons.contact_support_outlined,
                    //         title: 'Contact Us',
                    //         subtitle: 'Reach out to our team',
                    //         iconColor: Colors.cyan.shade600,
                    //         width: width,
                    //         onTap: () {
                    //           showDialog(
                    //             context: context,
                    //             builder: (context) => AlertDialog(
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20),
                    //               ),
                    //               title: Row(
                    //                 children: [
                    //                   Icon(Icons.contact_support, color: Colors.cyan.shade600),
                    //                   SizedBox(width: 10),
                    //                   Text('Contact Us'),
                    //                 ],
                    //               ),
                    //               content: Column(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text('Email: support@example.com'),
                    //                   SizedBox(height: 8),
                    //                   Text('Phone: +92 300 1234567'),
                    //                   SizedBox(height: 8),
                    //                   Text('Address: Islamabad, Pakistan'),
                    //                 ],
                    //               ),
                    //               actions: [
                    //                 TextButton(
                    //                   onPressed: () => Navigator.pop(context),
                    //                   child: Text('Close'),
                    //                 ),
                    //               ],
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       _Divider(),
                    //       _SettingsTile(
                    //         icon: Icons.privacy_tip_outlined,
                    //         title: 'Privacy Policy',
                    //         subtitle: 'Read our privacy policy',
                    //         iconColor: Colors.amber.shade700,
                    //         width: width,
                    //         onTap: () {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text('Opening Privacy Policy...'),
                    //               behavior: SnackBarBehavior.floating,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       _Divider(),
                    //       _SettingsTile(
                    //         icon: Icons.description_outlined,
                    //         title: 'Terms of Service',
                    //         subtitle: 'View terms and conditions',
                    //         iconColor: Colors.brown.shade600,
                    //         width: width,
                    //         onTap: () {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text('Opening Terms of Service...'),
                    //               behavior: SnackBarBehavior.floating,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // SizedBox(height: height * 0.03),

                    // // About Section
                    // _SectionHeader(
                    //   title: 'About',
                    //   width: width,
                    // ),
                    // SizedBox(height: height * 0.015),
                    // _SettingsCard(
                    //   child: Column(
                    //     children: [
                    //       _SettingsTile(
                    //         icon: Icons.info_outline_rounded,
                    //         title: 'App Version',
                    //         subtitle: 'Version 1.0.0',
                    //         iconColor: Colors.grey.shade600,
                    //         width: width,
                    //       ),
                    //       _Divider(),
                    //       _SettingsTile(
                    //         icon: Icons.rate_review_outlined,
                    //         title: 'Rate App',
                    //         subtitle: 'Rate us on Play Store',
                    //         iconColor: Colors.pink.shade600,
                    //         width: width,
                    //         onTap: () {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text('Opening Play Store...'),
                    //               behavior: SnackBarBehavior.floating,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       _Divider(),
                    //       _SettingsTile(
                    //         icon: Icons.share_outlined,
                    //         title: 'Share App',
                    //         subtitle: 'Share with friends',
                    //         iconColor: Colors.lightBlue.shade600,
                    //         width: width,
                    //         onTap: () {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text('Opening Share Dialog...'),
                    //               behavior: SnackBarBehavior.floating,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(height: height * 0.03),

                    // Logout Button
                    Container(
                      width: double.infinity,
                      height: height * 0.07,
                      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
                      child: ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: Icon(Icons.logout_rounded, size: width * 0.05),
                        label: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.red.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Made with ❤️ in Pakistan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: width * 0.032,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            '© 2024 Find Masjid. All rights reserved.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: width * 0.028,
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
          ],
        ),
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final double width;

  const _SectionHeader({
    required this.title,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: Text(
        title,
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Settings Card Widget
class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final double width;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.width,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.01,
      ),
      leading: Container(
        width: width * 0.11,
        height: width * 0.11,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: width * 0.06,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: width * 0.032,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ?? (onTap != null
          ? Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: width * 0.06,
            )
          : null),
    );
  }
}

// Divider Widget
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      color: Colors.grey[200],
    );
  }
}