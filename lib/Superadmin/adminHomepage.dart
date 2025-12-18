// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Adminhomepage extends StatefulWidget {
//   const Adminhomepage({super.key});

//   @override
//   State<Adminhomepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Adminhomepage> {
  
//  GoogleMapController? mapController;
//   LatLng selectedPos = const LatLng(25.3960, 68.3578);
//   Set<Marker> markers = {};

//   List<dynamic> mosquesData = [];

//   BitmapDescriptor? mosqueIcon;

//   @override
//   void initState() {
//     super.initState();
//     _loadJsonData();
//     _loadMosqueIcon();
//   }

// void _loadMosqueIcon() async {
//   mosqueIcon = await BitmapDescriptor.fromAssetImage(
//     const ImageConfiguration(size: Size(48, 48)),
//     'assets/icon/location.png',
//   );
// }
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
//           icon: 
//           BitmapDescriptor.defaultMarkerWithHue(
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
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: const Text(
//           'Mosque Finder',
//           style: TextStyle(color: Colors.white),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(kToolbarHeight),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SearchBar(
//               leading: const Icon(Icons.search),
//               onTap: () {},
//               hintText: 'Search Masjid Here',
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: GoogleMap(
//           initialCameraPosition: CameraPosition(target: selectedPos, zoom: 14),
//           onMapCreated: (controller) => mapController = controller,
//           markers: markers, // Use the markers set here
//           myLocationEnabled: true,
//           myLocationButtonEnabled: true,
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
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Adminhomepage extends StatefulWidget {
  const Adminhomepage({super.key});

  @override
  State<Adminhomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<Adminhomepage> {
  GoogleMapController? mapController;
  LatLng? selectedPos ;
  bool isMapReady = false;
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

  Future<LatLng?> _getCurrentLatLng() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }

  if (permission == LocationPermission.deniedForever) return null;

  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return LatLng(position.latitude, position.longitude);
}

Future<void> _moveToCurrentLocation() async {
  final currentLatLng = await _getCurrentLatLng();

  if (currentLatLng != null && mapController != null) {
    setState(() {
      selectedPos = currentLatLng;
    });

    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 15,
        ),
      ),
    );
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
          markerId: MarkerId('${mosque.id}_${mosque.lat}_${mosque.lng}'),
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
                target: selectedPos ?? const LatLng(25.3960, 68.3578),
                zoom: 14,
                ),
                // onMapCreated: (controller) => mapController = controller,
                 onMapCreated: (controller) async {
    mapController = controller;
    isMapReady = true;

    // 🔥 NOW move to current location
    await _moveToCurrentLocation();
  },
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