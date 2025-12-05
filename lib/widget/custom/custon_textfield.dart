// import 'package:flutter/material.dart';
// import 'package:flutter/src/services/text_formatter.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final String hintText;
  
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
  
//   final String? Function(String?)? validator;

//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.labelText,
//     required this.hintText,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text, 
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator, required List<TextInputFormatter> inputFormatters, 
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
      
     
//       validator: validator,
//      decoration: InputDecoration(
//       labelText: labelText,
//       labelStyle: const TextStyle(color: Colors.green),
//       floatingLabelStyle: const TextStyle(color: Colors.green),
//       hintText: hintText,
//       prefixIcon: prefixIcon,
//       suffixIcon: suffixIcon,
     
//       border: const OutlineInputBorder(
//         borderRadius: BorderRadius.all(Radius.circular(10.0)),
//         borderSide: BorderSide(color: Colors.grey, width: 1.0), 
//       ),
      
    
//       enabledBorder: const OutlineInputBorder(
//         borderRadius: BorderRadius.all(Radius.circular(10.0)),
//         borderSide: BorderSide(color: Colors.grey, width: 1.0),
//       ),
      
    
//       focusedBorder: const OutlineInputBorder(
//         borderRadius: BorderRadius.all(Radius.circular(10.0)),
//         borderSide: BorderSide(color: Colors.green, width: 2.0),
//       ),
    
//       errorBorder: const OutlineInputBorder(
//         borderRadius: BorderRadius.all(Radius.circular(10.0)),
//         borderSide: BorderSide(color: Colors.red, width: 2.0),
//       ),
//       focusedErrorBorder: const OutlineInputBorder(
//         borderRadius: BorderRadius.all(Radius.circular(10.0)),
//         borderSide: BorderSide(color: Colors.red, width: 2.0),
//       ),
//     ), 
     
//     );
//   }
// }
// custon_textfield.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.labelText = '',
    this.hintText = '',
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[900],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText.isEmpty ? null : labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        
        // Label style
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.green.shade700,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        
        // Hint style
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        
        // Border styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade600, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        
        // Fill and padding
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        // Error style
        errorStyle: TextStyle(
          fontSize: 12,
          height: 0.8,
        ),
        
        // Counter
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}