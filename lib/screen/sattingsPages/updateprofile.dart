// import 'dart:io';
// import 'package:find_masjid/widget/custom/custon_textfield.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();

//   bool isLoading = false;
//   bool isUploadingImage = false;
//   bool profileUpdated = false;
//   String? _profileImageUrl;
//   File? _selectedImage;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   final user = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize animations
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _animationController.forward();

//     // Load existing user data
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       if (user != null) {
//         // Set name from Firebase Auth
//         _nameController.text = user!.displayName ?? '';
//         _profileImageUrl = user!.photoURL;

//         // Load additional data from Firestore
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user!.uid)
//             .get();

//         if (doc.exists) {
//           final data = doc.data();
//           _phoneController.text = data?['phone'] ?? '';
//           _addressController.text = data?['address'] ?? '';
//           _bioController.text = data?['bio'] ?? '';
//           _profileImageUrl = data?['profileImageUrl'] ?? _profileImageUrl;
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(child: Text('Failed to load profile data')),
//               ],
//             ),
//             backgroundColor: Colors.orange.shade700,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: source,
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 75,
//       );

//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(child: Text('Failed to pick image')),
//               ],
//             ),
//             backgroundColor: Colors.red.shade600,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//       }
//     }
//   }

//   void _showImagePickerOptions() {
//     final width = MediaQuery.of(context).size.width;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(width * 0.05),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(25),
//             topRight: Radius.circular(25),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle bar
//             Container(
//               width: width * 0.1,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             SizedBox(height: width * 0.05),
//             Text(
//               'Choose Profile Photo',
//               style: TextStyle(
//                 fontSize: width * 0.045,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             SizedBox(height: width * 0.05),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _ImagePickerOption(
//                   icon: Icons.camera_alt_rounded,
//                   label: 'Camera',
//                   color: Colors.blue,
//                   width: width,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.camera);
//                   },
//                 ),
//                 _ImagePickerOption(
//                   icon: Icons.photo_library_rounded,
//                   label: 'Gallery',
//                   color: Colors.green,
//                   width: width,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.gallery);
//                   },
//                 ),
//                 if (_profileImageUrl != null || _selectedImage != null)
//                   _ImagePickerOption(
//                     icon: Icons.delete_rounded,
//                     label: 'Remove',
//                     color: Colors.red,
//                     width: width,
//                     onTap: () {
//                       Navigator.pop(context);
//                       setState(() {
//                         _selectedImage = null;
//                         _profileImageUrl = null;
//                       });
//                     },
//                   ),
//               ],
//             ),
//             SizedBox(height: width * 0.05),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: width * 0.04,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<String?> _uploadImage() async {
//     if (_selectedImage == null) return _profileImageUrl;

//     try {
//       setState(() {
//         isUploadingImage = true;
//       });

//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('profile_images')
//           .child('${user!.uid}.jpg');

//       await ref.putFile(_selectedImage!);
//       final url = await ref.getDownloadURL();

//       return url;
//     } catch (e) {
//       throw Exception('Failed to upload image');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isUploadingImage = false;
//         });
//       }
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Dismiss keyboard
//     FocusScope.of(context).unfocus();

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       String? imageUrl = _profileImageUrl;

//       // Upload new image if selected
//       if (_selectedImage != null) {
//         imageUrl = await _uploadImage();
//       }

//       // Update Firebase Auth profile
//       await user!.updateDisplayName(_nameController.text.trim());
//       if (imageUrl != null) {
//         await user!.updatePhotoURL(imageUrl);
//       }

//       // Update Firestore document
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .set({
//         'name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'address': _addressController.text.trim(),
//         'bio': _bioController.text.trim(),
//         'profileImageUrl': imageUrl,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       if (mounted) {
//         setState(() {
//           profileUpdated = true;
//           _profileImageUrl = imageUrl;
//           _selectedImage = null;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white),
//                 const SizedBox(width: 10),
//                 const Expanded(
//                   child: Text('Profile updated successfully!'),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(child: Text('Failed to update profile: ${e.toString()}')),
//               ],
//             ),
//             backgroundColor: Colors.red.shade600,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   String? _nameValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Name is required';
//     }
//     if (value.length < 2) {
//       return 'Name must be at least 2 characters';
//     }
//     if (value.length > 50) {
//       return 'Name must be less than 50 characters';
//     }
//     return null;
//   }

//   String? _phoneValidator(String? value) {
//     if (value != null && value.isNotEmpty) {
//       if (value.length < 10 || value.length > 15) {
//         return 'Please enter a valid phone number';
//       }
//       if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
//         return 'Phone number contains invalid characters';
//       }
//     }
//     return null;
//   }

//   String? _bioValidator(String? value) {
//     if (value != null && value.length > 200) {
//       return 'Bio must be less than 200 characters';
//     }
//     return null;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _bioController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final height = size.height;
//     final width = size.width;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: width * 0.06),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: height * 0.02),

//                       // App Bar
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
//                             onPressed: () => Navigator.pop(context),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                           ),
//                           Text(
//                             'Edit Profile',
//                             style: TextStyle(
//                               fontSize: width * 0.05,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[900],
//                             ),
//                           ),
//                           // Save button in app bar
//                           TextButton(
//                             onPressed: isLoading ? null : _updateProfile,
//                             child: isLoading
//                                 ? SizedBox(
//                                     width: width * 0.05,
//                                     height: width * 0.05,
//                                     child: const CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : Text(
//                                     'Save',
//                                     style: TextStyle(
//                                       color: Colors.green.shade600,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: width * 0.04,
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Profile Picture Section
//                       Center(
//                         child: Stack(
//                           children: [
//                             // Profile Image
//                             GestureDetector(
//                               onTap: _showImagePickerOptions,
//                               child: Container(
//                                 width: width * 0.32,
//                                 height: width * 0.32,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey[200],
//                                   border: Border.all(
//                                     color: Colors.green.shade400,
//                                     width: 3,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.green.withOpacity(0.2),
//                                       blurRadius: 15,
//                                       offset: const Offset(0, 5),
//                                     ),
//                                   ],
//                                   image: _selectedImage != null
//                                       ? DecorationImage(
//                                           image: FileImage(_selectedImage!),
//                                           fit: BoxFit.cover,
//                                         )
//                                       : _profileImageUrl != null
//                                           ? DecorationImage(
//                                               image: NetworkImage(_profileImageUrl!),
//                                               fit: BoxFit.cover,
//                                             )
//                                           : null,
//                                 ),
//                                 child: _selectedImage == null && _profileImageUrl == null
//                                     ? Icon(
//                                         Icons.person_rounded,
//                                         size: width * 0.15,
//                                         color: Colors.grey[400],
//                                       )
//                                     : null,
//                               ),
//                             ),
//                             // Camera Icon
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: GestureDetector(
//                                 onTap: _showImagePickerOptions,
//                                 child: Container(
//                                   width: width * 0.1,
//                                   height: width * 0.1,
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade600,
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white,
//                                       width: 3,
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.2),
//                                         blurRadius: 5,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Icon(
//                                     Icons.camera_alt_rounded,
//                                     color: Colors.white,
//                                     size: width * 0.05,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Upload Progress
//                             if (isUploadingImage)
//                               Positioned.fill(
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.5),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Center(
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 3,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: height * 0.01),

//                       // Change Photo Text
//                       Center(
//                         child: TextButton(
//                           onPressed: _showImagePickerOptions,
//                           child: Text(
//                             'Change Profile Photo',
//                             style: TextStyle(
//                               color: Colors.green.shade600,
//                               fontSize: width * 0.035,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Email Display (Read Only)
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(width * 0.04),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.email_outlined,
//                               color: Colors.grey[600],
//                               size: width * 0.05,
//                             ),
//                             SizedBox(width: width * 0.03),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Email',
//                                     style: TextStyle(
//                                       fontSize: width * 0.03,
//                                       color: Colors.grey[500],
//                                     ),
//                                   ),
//                                   Text(
//                                     user?.email ?? 'Not available',
//                                     style: TextStyle(
//                                       fontSize: width * 0.038,
//                                       color: Colors.grey[800],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: width * 0.02,
//                                 vertical: width * 0.01,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: user?.emailVerified == true
//                                     ? Colors.green.shade50
//                                     : Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     user?.emailVerified == true
//                                         ? Icons.verified_rounded
//                                         : Icons.warning_rounded,
//                                     color: user?.emailVerified == true
//                                         ? Colors.green
//                                         : Colors.orange,
//                                     size: width * 0.04,
//                                   ),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     user?.emailVerified == true ? 'Verified' : 'Unverified',
//                                     style: TextStyle(
//                                       fontSize: width * 0.028,
//                                       color: user?.emailVerified == true
//                                           ? Colors.green
//                                           : Colors.orange,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Personal Information Section Header
//                       _SectionHeader(
//                         title: 'Personal Information',
//                         icon: Icons.person_outline,
//                         width: width,
//                       ),

//                       SizedBox(height: height * 0.02),

//                       // Full Name Field
//                       Text(
//                         'Full Name *',
//                         style: TextStyle(
//                           fontSize: width * 0.035,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.01),
//                       CustomTextField(
//                         controller: _nameController,
//                         labelText: '',
//                         hintText: 'Enter your full name',
//                         prefixIcon: const Icon(Icons.person_outline, color: Colors.green),
//                         validator: _nameValidator,
//                         keyboardType: TextInputType.name,
//                       ),

//                       SizedBox(height: height * 0.02),

//                       // Phone Number Field
//                       Text(
//                         'Phone Number',
//                         style: TextStyle(
//                           fontSize: width * 0.035,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.01),
//                       CustomTextField(
//                         controller: _phoneController,
//                         labelText: '',
//                         hintText: 'Enter your phone number',
//                         prefixIcon: const Icon(Icons.phone_outlined, color: Colors.green),
//                         validator: _phoneValidator,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
//                           LengthLimitingTextInputFormatter(15),
//                         ],
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Additional Information Section Header
//                       _SectionHeader(
//                         title: 'Additional Information',
//                         icon: Icons.info_outline,
//                         width: width,
//                       ),

//                       SizedBox(height: height * 0.02),

//                       // Address Field
//                       Text(
//                         'Address',
//                         style: TextStyle(
//                           fontSize: width * 0.035,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.01),
//                       CustomTextField(
//                         controller: _addressController,
//                         labelText: '',
//                         hintText: 'Enter your address',
//                         prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.green),
//                         keyboardType: TextInputType.streetAddress,
//                       ),

//                       SizedBox(height: height * 0.02),

//                       // Bio Field
//                       Text(
//                         'Bio',
//                         style: TextStyle(
//                           fontSize: width * 0.035,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.01),
//                       CustomTextField(
//                         controller: _bioController,
//                         labelText: '',
//                         hintText: 'Write something about yourself...',
//                         prefixIcon: const Icon(Icons.edit_note_outlined, color: Colors.green),
//                         validator: _bioValidator,
//                         keyboardType: TextInputType.multiline,
//                         maxLines: 3,
//                         maxLength: 200,
//                       ),

//                       SizedBox(height: height * 0.04),

//                       // Update Profile Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: height * 0.07,
//                         child: ElevatedButton.icon(
//                           onPressed: isLoading ? null : _updateProfile,
//                           icon: isLoading
//                               ? const SizedBox.shrink()
//                               : Icon(Icons.check_circle_outline, size: width * 0.05),
//                           label: isLoading
//                               ? SizedBox(
//                                   width: width * 0.06,
//                                   height: width * 0.06,
//                                   child: const CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2.5,
//                                   ),
//                                 )
//                               : Text(
//                                   'Save Changes',
//                                   style: TextStyle(
//                                     fontSize: width * 0.04,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green.shade600,
//                             foregroundColor: Colors.white,
//                             elevation: 2,
//                             shadowColor: Colors.green.withOpacity(0.4),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             disabledBackgroundColor: Colors.grey.shade300,
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: height * 0.02),

//                       // Cancel Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: height * 0.06,
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.grey[700],
//                             side: BorderSide(color: Colors.grey[300]!, width: 1.5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontSize: width * 0.04,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Danger Zone
//                       _DangerZone(
//                         width: width,
//                         height: height,
//                         onDeleteAccount: () => _showDeleteAccountDialog(),
//                       ),

//                       SizedBox(height: height * 0.03),
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

//   void _showDeleteAccountDialog() {
//     final width = MediaQuery.of(context).size.width;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.warning_rounded, color: Colors.red.shade600),
//             const SizedBox(width: 10),
//             const Text('Delete Account'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Are you sure you want to delete your account?',
//               style: TextStyle(fontSize: width * 0.04),
//             ),
//             SizedBox(height: width * 0.03),
//             Container(
//               padding: EdgeInsets.all(width * 0.03),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.red.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: Colors.red.shade700,
//                     size: width * 0.05,
//                   ),
//                   SizedBox(width: width * 0.02),
//                   Expanded(
//                     child: Text(
//                       'This action cannot be undone. All your data will be permanently deleted.',
//                       style: TextStyle(
//                         fontSize: width * 0.032,
//                         color: Colors.red.shade900,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Implement delete account logic
//               _deleteAccount();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade600,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteAccount() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       // Delete Firestore data
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .delete();

//       // Delete Storage profile image
//       try {
//         await FirebaseStorage.instance
//             .ref()
//             .child('profile_images')
//             .child('${user!.uid}.jpg')
//             .delete();
//       } catch (e) {
//         // Image might not exist
//       }

//       // Delete Firebase Auth account
//       await user!.delete();

//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (mounted) {
//         String message = 'Failed to delete account';
//         if (e.code == 'requires-recent-login') {
//           message = 'Please log out and log in again before deleting your account.';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(child: Text(message)),
//               ],
//             ),
//             backgroundColor: Colors.red.shade600,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
// }

// class FirebaseFirestore {
// }

// // Section Header Widget
// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final double width;

//   const _SectionHeader({
//     required this.title,
//     required this.icon,
//     required this.width,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: Colors.green.shade600,
//           size: width * 0.05,
//         ),
//         SizedBox(width: width * 0.02),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: width * 0.042,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Image Picker Option Widget
// class _ImagePickerOption extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final double width;
//   final VoidCallback onTap;

//   const _ImagePickerOption({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.width,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: width * 0.15,
//             height: width * 0.15,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: width * 0.07,
//             ),
//           ),
//           SizedBox(height: width * 0.02),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: width * 0.032,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Danger Zone Widget
// class _DangerZone extends StatelessWidget {
//   final double width;
//   final double height;
//   final VoidCallback onDeleteAccount;

//   const _DangerZone({
//     required this.width,
//     required this.height,
//     required this.onDeleteAccount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(width * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.warning_rounded,
//                 color: Colors.red.shade600,
//                 size: width * 0.05,
//               ),
//               SizedBox(width: width * 0.02),
//               Text(
//                 'Danger Zone',
//                 style: TextStyle(
//                   fontSize: width * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red.shade900,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: height * 0.015),
//           Text(
//             'Once you delete your account, there is no going back. Please be certain.',
//             style: TextStyle(
//               fontSize: width * 0.032,
//               color: Colors.red.shade800,
//               height: 1.4,
//             ),
//           ),
//           SizedBox(height: height * 0.02),
//           SizedBox(
//             width: double.infinity,
//             height: height * 0.055,
//             child: OutlinedButton.icon(
//               onPressed: onDeleteAccount,
//               icon: Icon(Icons.delete_forever_rounded, size: width * 0.05),
//               label: Text(
//                 'Delete Account',
//                 style: TextStyle(
//                   fontSize: width * 0.035,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red.shade700,
//                 side: BorderSide(color: Colors.red.shade400, width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }