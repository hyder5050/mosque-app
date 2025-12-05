// import 'package:flutter/material.dart';

// class MapStyleApp extends StatelessWidget {
//   const MapStyleApp({super.key});

//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 1. Base Map and Stylized River/Road
//           Positioned.fill(
//             child: Container(
//               color: const Color(0xFF191932), // Deep dark blue background
//             ),
//           ),
          
//           // Simulation of the stylized river/road structure
//           Positioned(
//             left: 100,
//             right: 50,
//             top: 0,
//             bottom: 0,
//             child: CustomPaint(
//               painter: RiverRoadPainter(),
//             ),
//           ),

//           // 2. Heatmap Overlays (Simulated using blurred, colored containers)
//           // Red Hotspot 1 (Center-right)
//           const Positioned(
//             top: 250,
//             left: 180,
//             child: HeatmapSpot(color: Color(0xFFFF5252), size: 120),
//           ),
//           // Yellow Hotspot 2 (Center-left)
//           const Positioned(
//             top: 400,
//             left: 50,
//             child: HeatmapSpot(color: Color(0xFFFFEB3B), size: 150),
//           ),
//           // Yellow Hotspot 3 (Bottom-left)
//           const Positioned(
//             top: 550,
//             left: 10,
//             child: HeatmapSpot(color: Color(0xFFFFC107), size: 100),
//           ),

//           // 3. Custom Bitmoji Markers and POIs
//           // POI - Cafe Kanjhar
//           const Positioned(
//             top: 200,
//             left: 130,
//             child: MapPoiLabel(
//               icon: Icons.restaurant,
//               label: 'Cafe Kanjhar\n& B.B.Q',
//             ),
//           ),
//           // POI - University Circle
//           const Positioned(
//             top: 380,
//             left: 20,
//             child: MapPoiLabel(
//               icon: Icons.school,
//               label: 'University Circle',
//             ),
//           ),
//           // POI - Sri Guru Nanak
//           const Positioned(
//             top: 300,
//             left: 250,
//             child: MapPoiLabel(
//               icon: Icons.church,
//               label: 'Sri Guru Nanak\nDev Ji Trust',
//             ),
//           ),
//           // POI - Salateen Hotel
//           const Positioned(
//             top: 320,
//             right: 20,
//             child: MapPoiLabel(
//               icon: Icons.local_cafe,
//               label: 'Salateen Hotel',
//             ),
//           ),
//           // POI - Mehran University
//           const Positioned(
//             top: 470,
//             left: 30,
//             child: MapPoiLabel(
//               icon: Icons.apartment,
//               label: 'Mehran University\nInstitute of Science,\nTechnology & Development',
//             ),
//           ),
//           // POI - Boulevard Mall
//           const Positioned(
//             bottom: 120,
//             right: 0,
//             child: MapPoiLabel(
//               icon: Icons.shopping_bag,
//               label: 'Boulevard Mall\nVisited',
//             ),
//           ),
//           // POI - KFC
//           const Positioned(
//             top: 370,
//             right: 120,
//             child: MapPoiLabel(
//               icon: Icons.fastfood,
//               label: 'KFC\nTop Pick',
//             ),
//           ),

//           // Bitmoji Markers (Avatars)
//           // Bitmoji 1 (Top Left)
//           const Positioned(
//             top: 260,
//             left: 150,
//             child: BitmojiMarker(
//               label: 'Sanam',
//               time: '7h',
//               // Using a placeholder icon for the Bitmoji avatar
//               icon: Icons.person_2_rounded,
//               color: Color(0xFF558B2F),
//             ),
//           ),
//           // Bitmoji 2 (Center)
//           const Positioned(
//             top: 400,
//             left: 200,
//             child: BitmojiMarker(
//               label: 'Jullianna',
//               icon: Icons.person_3_rounded,
//               color: Color(0xFF6A1B9A),
//             ),
//           ),
//           // Bitmoji 3 (Center-right)
//           const Positioned(
//             top: 460,
//             right: 130,
//             child: BitmojiMarker(
//               label: 'McDona',
//               icon: Icons.person_4_rounded,
//               color: Color(0xFF388E3C),
//             ),
//           ),
//           // Bitmoji 4 (Group, Right)
//           const Positioned(
//             top: 420,
//             right: 50,
//             child: BitmojiMarker(
//               label: 'Squad',
//               icon: Icons.people_alt,
//               color: Color(0xFFD32F2F),
//             ),
//           ),

//           // 4. Floating UI Elements (Top Bar)
//           const MapAppBar(),

//           // 5. Floating UI Elements (Right Vertical Buttons)
//           const Positioned(
//             top: 150,
//             right: 10,
//             child: RightMapButtons(),
//           ),

//           // 6. Floating UI Elements (Bottom Center Compass)
//           const Positioned(
//             bottom: 20,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: FloatingMapButton(
//                 icon: Icons.send_rounded,
//                 color: Color(0xFF263238),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- Custom Painter for the River/Road Stylization ---

// class RiverRoadPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF2E3D4F) // Darker blue for river/road
//       ..style = PaintingStyle.fill;

//     final path = Path()
//       // Start near the top center
//       ..moveTo(size.width * 0.5, 0)
//       // Wavy path down the center
//       ..quadraticBezierTo(size.width * 0.45, size.height * 0.2, size.width * 0.6, size.height * 0.4)
//       ..cubicTo(size.width * 0.7, size.height * 0.6, size.width * 0.3, size.height * 0.7, size.width * 0.55, size.height)
//       // Widen the path
//       ..lineTo(size.width * 0.65, size.height)
//       ..cubicTo(size.width * 0.4, size.height * 0.75, size.width * 0.75, size.height * 0.5, size.width * 0.5, size.height * 0.2)
//       ..quadraticBezierTo(size.width * 0.55, 0, size.width * 0.5, 0)
//       ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // --- Reusable Widgets ---

// class HeatmapSpot extends StatelessWidget {
//   final Color color;
//   final double size;

//   const HeatmapSpot({
//     super.key,
//     required this.color,
//     required this.size,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.4),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.8),
//             blurRadius: size / 2, // The key for the blur effect
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MapPoiLabel extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const MapPoiLabel({
//     super.key,
//     required this.icon,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Icon(icon, color: Colors.blueAccent, size: 20),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class BitmojiMarker extends StatelessWidget {
//   final String label;
//   final String? time;
//   final IconData icon;
//   final Color color;

//   const BitmojiMarker({
//     super.key,
//     required this.label,
//     this.time,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Marker Tag (like the "Sanam 7h" box)
//         if (time != null || label.isNotEmpty)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.black, width: 2),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (time != null) ...[
//                   const SizedBox(width: 4),
//                   Text(
//                     time!,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
        
//         // Bitmoji/Avatar Placeholder
//         Container(
//           width: 45,
//           height: 45,
//           margin: const EdgeInsets.only(top: 4),
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 5,
//                 spreadRadius: 1,
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class MapAppBar extends StatelessWidget {
//   const MapAppBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 40,
//       left: 10,
//       right: 10,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left: User Profile Icon
//           const FloatingMapButton(
//             icon: Icons.person,
//             color: Color(0xFF3E4F63),
//           ),

//           // Center: Search/Location Bar
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFF3E4F63),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: const Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.cloudy_snowing, color: Colors.white70, size: 18),
//                 SizedBox(width: 8),
//                 Text(
//                   'Hyderabad',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   '63°F',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Right: Settings Icon
//           const FloatingMapButton(
//             icon: Icons.settings,
//             color: Color(0xFF3E4F63),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RightMapButtons extends StatelessWidget {
//   const RightMapButtons({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         FloatingMapButton(icon: Icons.public, color: Colors.black.withOpacity(0.5)),
//         const SizedBox(height: 10),
//         FloatingMapButton(icon: Icons.pin_drop, color: Colors.black.withOpacity(0.5)),
//         const SizedBox(height: 10),
//         FloatingMapButton(icon: Icons.grid_view, color: Colors.black.withOpacity(0.5)),
//       ],
//     );
//   }
// }

// class FloatingMapButton extends StatelessWidget {
//   final IconData icon;
//   final Color color;

//   const FloatingMapButton({
//     super.key,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 48,
//       height: 48,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 5,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Icon(icon, color: Colors.white, size: 24),
//     );
//   }
// }