// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   GoogleMapController? mapController;

//  LatLng selectedPos = const LatLng(25.3960, 68.3578);
//  Set <Marker> markers = {};

//   // void _onMapcreated(GoogleMapController controller) {
//   //   mapController = controller;
//   // }
//   void moveCameraTo(LatLng position){
//     mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: position, zoom: 16),
//       )
//     );
//     setState(() {
//       selectedPos = position;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         bottom: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight),
//         child: Padding(padding: EdgeInsets.all(8.0),
//         child: SearchBar(leading: Icon(Icons.search),
//         onTap: (){},
//         hintText: 'Search Masjid Here',)
//         ),
//       ),
//       ),
//       body:  SafeArea(
//         child: GoogleMap(
//           // onMapCreated: _onMapcreated,
//           initialCameraPosition: CameraPosition(
//             target: selectedPos,
//             // LatLng(25.355302, 68.344454),
//             zoom: 14,
//           ),
//           onMapCreated: (controller)=>mapController = controller,
//           markers: {
//             Marker(
//               markerId: MarkerId('selectedPos'),
//               position: selectedPos,
//             )
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:find_masjid/provider/mosqueProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GoogleMapController? mapController;
  LatLng selectedPos = const LatLng(25.3960, 68.3578);
  Set<Marker> markers = {};
  BitmapDescriptor? customMarkerIcon;
  bool isLoadingMarkers = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Load custom marker icon
    await _loadCustomMarker();

    // Load mosques from provider
    if (mounted) {
      final provider = Provider.of<MosqueProvider>(context, listen: false);
      await provider.loadMosques();
      _loadMosqueMarkers();
    }
  }

  // Load custom marker icon from assets
  Future<void> _loadCustomMarker() async {
    try {
      final ByteData data = await rootBundle.load('assets/icons/location.png');

      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 300, // 🔥 increase size (try 100–150)
        targetHeight: 300,
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? resizedBytes = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (resizedBytes != null) {
        customMarkerIcon = BitmapDescriptor.fromBytes(
          resizedBytes.buffer.asUint8List(),
        );
      }
    } catch (e) {
      debugPrint('Error loading custom marker: $e');
      customMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      );
    }
  }

  // Alternative method: Create custom marker from widget
  // Future<BitmapDescriptor> _createCustomMarkerFromWidget() async {
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color = Colors.green;

  //   // Draw custom marker shape
  //   const double size = 300;
  //   canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

  //   // Draw icon
  //   final icon = Icons.mosque_rounded;
  //   final TextPainter textPainter = TextPainter(
  //     textDirection: TextDirection.ltr,
  //   );
  //   textPainter.text = TextSpan(
  //     text: String.fromCharCode(icon.codePoint),
  //     style: TextStyle(
  //       fontSize: size * 0.6,
  //       fontFamily: icon.fontFamily,
  //       color: Colors.white,
  //     ),
  //   );
  //   textPainter.layout();
  //   textPainter.paint(
  //     canvas,
  //     Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
  //   );

  //   final img = await pictureRecorder.endRecording().toImage(
  //     size.toInt(),
  //     size.toInt(),
  //   );
  //   final data = await img.toByteData(format: ui.ImageByteFormat.png);

  //   return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  // }

  Future<ui.Image> _bytesToImage(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 120, // Resize for better performance
      targetHeight: 120,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  // Load markers from provider data
  void _loadMosqueMarkers() {
    final provider = Provider.of<MosqueProvider>(context, listen: false);
    Set<Marker> loadedMarkers = {};

    for (var mosque in provider.mosques) {
      loadedMarkers.add(
        Marker(
          markerId: MarkerId(mosque.id),
          position: LatLng(mosque.lat, mosque.lng),
          infoWindow: InfoWindow(
            title: mosque.name,
            snippet: mosque.address,
            onTap: () => _onMarkerTapped(mosque),
          ),
          icon:
              customMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => _onMarkerTapped(mosque),
        ),
      );
    }

    if (mounted) {
      setState(() {
        markers = loadedMarkers;
        isLoadingMarkers = false;
      });
    }
  }

  // Handle marker tap
  void _onMarkerTapped(Mosque mosque) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mosque icon and name
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              mosque.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Coordinates
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lat: ${mosque.lat.toStringAsFixed(4)}, Lng: ${mosque.lng.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _moveCameraToMosque(mosque);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Center'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _moveCameraToMosque(Mosque mosque) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(mosque.lat, mosque.lng), zoom: 16),
      ),
    );
    setState(() {
      selectedPos = LatLng(mosque.lat, mosque.lng);
    });
  }

  void moveCameraTo(LatLng position) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
    setState(() {
      selectedPos = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Consumer<MosqueProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedPos,
                  zoom: 14,
                ),
                onMapCreated: (controller) => mapController = controller,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Title Overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.mosque_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Mosque Finder',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Refresh button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () async {
                          setState(() => isLoadingMarkers = true);
                          await provider.refreshMosques();
                          _loadMosqueMarkers();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator
              if (isLoadingMarkers || provider.isLoading)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
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
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Loading mosques...',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Mosque count badge
              if (!isLoadingMarkers && markers.isNotEmpty)
                Positioned(
                  bottom: 100,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mosque_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${markers.length} Mosques',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   GoogleMapController? mapController;
//   LatLng selectedPos = const LatLng(25.3960, 68.3578);
//   Set<Marker> markers = {};

//   List<dynamic> mosquesData = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadJsonData();
//   }

//   Future<void> _loadJsonData() async {
//     final String response = await rootBundle.loadString('assets/mosque.json');
//     final jsonData = json.decode(response);

//     setState(() {
//       mosquesData = jsonData["mosquesData"];
//     });

//     print("JSON Loaded: ${mosquesData.length}");
//     _loadMosqueMarkers();
//   }

//   // Load markers from JSON data
//   void _loadMosqueMarkers() {
//     Set<Marker> loadedMarkers = {};

//     for (var mosque in mosquesData) {
//       loadedMarkers.add(
//         Marker(
//           markerId: MarkerId(mosque['id'].toString()),
//           position: LatLng(mosque['lat'], mosque['lng']),
//           infoWindow: InfoWindow(
//             title: mosque['name'],
//             snippet: 'Tap for directions',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen,
//           ),
//           onTap: () {
//             _onMarkerTapped(mosque);
//           },
//         ),
//       );
//     }

//     setState(() {
//       markers = loadedMarkers;
//     });
//   }

//   // Handle marker tap
//   void _onMarkerTapped(Map<String, dynamic> mosque) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         height: 150,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               mosque['name'],
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text('Lat: ${mosque['lat']}, Lng: ${mosque['lng']}'),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Add navigation logic here
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.directions),
//               label: const Text('Get Directions'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void moveCameraTo(LatLng position) {
//     mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: position, zoom: 16),
//       ),
//     );
//     setState(() {
//       selectedPos = position;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBodyBehindAppBar: true,

//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: selectedPos,
//               zoom: 14,
//             ),
//             onMapCreated: (controller) => mapController = controller,
//             markers: markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//           ),

//           // 🔥 Static Title Overlay
//           Positioned(
//             top:
//                 MediaQuery.of(context).padding.top + 12, // status bar ke neeche
//             left: 16,
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.4), // map readable rahe
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'Mosque Finder',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
