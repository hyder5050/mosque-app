import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Adminhomepage extends StatefulWidget {
  const Adminhomepage({super.key});

  @override
  State<Adminhomepage> createState() => _HomepageState();
}

class _HomepageState extends State<Adminhomepage> {
  
  GoogleMapController? mapController;
  LatLng selectedPos = const LatLng(25.3960, 68.3578);
  Set<Marker> markers = {};
  
  List <dynamic> mosquesData = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
  final String response = await rootBundle.loadString('assets/data/mosque.json');
  final data = json.decode(response);

  setState(() {
    mosquesData = data;
  });
  print('"JSON Loaded: ${mosquesData.length}"');

  _loadMosqueMarkers(); // markers load
}

  // Load markers from JSON data
  void _loadMosqueMarkers() {
    Set<Marker> loadedMarkers = {};
    
    for (var mosque in mosquesData) {
      loadedMarkers.add(
        Marker(
          markerId: MarkerId(mosque['id']),
          position: LatLng(mosque['latitude'], mosque['longitude']),
          infoWindow: InfoWindow(
            title: mosque['name'],
            snippet: 'Tap for directions',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen
              ),
          onTap: () {
            _onMarkerTapped(mosque);
          },
        ),
      );
    }
    
    setState(() {
      markers = loadedMarkers;
    });
  }

  // Handle marker tap
  void _onMarkerTapped(Map<String, dynamic> mosque) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mosque['name'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Lat: ${mosque['latitude']}, Lng: ${mosque['longitude']}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add navigation logic here
                Navigator.pop(context);
              },
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Mosque Finder', style: TextStyle(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              leading: const Icon(Icons.search),
              onTap: () {},
              hintText: 'Search Masjid Here',
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: selectedPos,
            zoom: 14,
          ),
          onMapCreated: (controller) => mapController = controller,
          markers: markers,  // Use the markers set here
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }
}