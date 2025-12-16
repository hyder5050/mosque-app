import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:find_masjid/widget/custom/custon_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMosquelist extends StatefulWidget {
  const AdminMosquelist({super.key});

  @override
  State<AdminMosquelist> createState() => _AdminMosquelistState();
}

class _AdminMosquelistState extends State<AdminMosquelist>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Mosque> _allMosques = [];
  List<Mosque> _filteredMosques = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _isGridView = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Load mosques
    _loadMosques();

    // Listen to search changes
    _searchController.addListener(_filterMosques);
  }

  Future<void> _loadMosques() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mosques')
          .get();
      // final String response = await rootBundle.loadString('assets/mosque.json');
      // final data = json.decode(response);

      // final mosques = (data['mosquesData'] as List)
      //     .map((e) => Mosque.fromJson(e))
      //     .toList();
      final mosques = snapshot.docs
          .map((doc) => Mosque.fromFirestore(doc))
          .toList();

      setState(() {
        _allMosques = mosques;
        _filteredMosques = mosques;
        isLoading = false;
      });

      _sortMosques();
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load mosques. Please try again.';
      });
    }
  }

  void _filterMosques() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredMosques = List.from(_allMosques);
      } else {
        _filteredMosques = _allMosques.where((mosque) {
          return mosque.name.toLowerCase().contains(query) ||
              mosque.address.toLowerCase().contains(query);
        }).toList();
      }
    });

    _sortMosques();
  }

  void _sortMosques() {
    setState(() {
      if (_sortBy == 'name') {
        _filteredMosques.sort((a, b) => a.name.compareTo(b.name));
      } else {
        _filteredMosques.sort((a, b) => a.address.compareTo(b.address));
      }
    });
  }

  void _showSortOptions() {
    final width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(width * 0.05),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: width * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: width * 0.05),
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: width * 0.04),
            _SortOption(
              icon: Icons.sort_by_alpha_rounded,
              title: 'Name (A-Z)',
              isSelected: _sortBy == 'name',
              width: width,
              onTap: () {
                setState(() => _sortBy = 'name');
                _sortMosques();
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.location_on_outlined,
              title: 'Address',
              isSelected: _sortBy == 'address',
              width: width,
              onTap: () {
                setState(() => _sortBy = 'address');
                _sortMosques();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: width * 0.04),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show options when mosque is tapped
  void _showMosqueOptions(Mosque mosque) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(width * 0.05),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: width * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: height * 0.025),

            // Mosque Info Header
            Row(
              children: [
                Container(
                  width: width * 0.15,
                  height: width * 0.15,
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: width * 0.08,
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: width * 0.04,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: width * 0.01),
                          Expanded(
                            child: Text(
                              mosque.address,
                              style: TextStyle(
                                fontSize: width * 0.032,
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

            SizedBox(height: height * 0.03),

            // Divider
            Divider(color: Colors.grey[200], thickness: 1),

            SizedBox(height: height * 0.01),

            // Option: Open in Google Maps
            _OptionTile(
              icon: Icons.map_rounded,
              iconColor: Colors.red,
              title: 'Open in Google Maps',
              subtitle: 'Navigate using Google Maps app',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _openInGoogleMaps(mosque);
              },
            ),

            // Option: Get Directions
            _OptionTile(
              icon: Icons.directions_rounded,
              iconColor: Colors.blue,
              title: 'Get Directions',
              subtitle: 'Turn-by-turn navigation',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _getDirections(mosque);
              },
            ),

            // Option: Show on App Map
            _OptionTile(
              icon: Icons.pin_drop_rounded,
              iconColor: Colors.green,
              title: 'Show on App Map',
              subtitle: 'View location in app',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _showOnAppMap(mosque);
              },
            ),

            // Option: Share Location
            _OptionTile(
              icon: Icons.share_rounded,
              iconColor: Colors.purple,
              title: 'Share Location',
              subtitle: 'Share mosque location with others',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _shareLocation(mosque);
              },
            ),

            SizedBox(height: height * 0.02),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: height * 0.06,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.01),
          ],
        ),
      ),
    );
  }

  // Open mosque location in Google Maps
  Future<void> _openInGoogleMaps(Mosque mosque) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${mosque.lat},${mosque.lng}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar('Could not open Google Maps');
      }
    } catch (e) {
      _showErrorSnackbar('Error opening Google Maps');
    }
  }

  // Get directions to mosque in Google Maps
  Future<void> _getDirections(Mosque mosque) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${mosque.lat},${mosque.lng}&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar('Could not open Google Maps');
      }
    } catch (e) {
      _showErrorSnackbar('Error opening Google Maps');
    }
  }

  // Show mosque on app's map
  void _showOnAppMap(Mosque mosque) {
    Navigator.pop(context, LatLng(mosque.lat, mosque.lng));
  }

  // Share mosque location
  Future<void> _shareLocation(Mosque mosque) async {
    final shareText =
        '${mosque.name}\n\n'
        '📍 ${mosque.address}\n\n'
        '🗺️ Open in Google Maps:\n'
        'https://www.google.com/maps/search/?api=1&query=${mosque.lat},${mosque.lng}';

    // You can use share_plus package for sharing
    // For now, we'll copy to clipboard
    await Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Location copied to clipboard!')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  //   void _showAddMosqueDialog() {
  //   final nameCtrl = TextEditingController();
  //   final addressCtrl = TextEditingController();
  //   final latCtrl = TextEditingController();
  //   final lngCtrl = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: const Text('Add New Mosque'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //             CustomTextField(controller: nameCtrl, labelText: 'Mosque Name'),
  //             SizedBox(height: 10),
  //             CustomTextField(controller: addressCtrl, labelText: 'Address'),
  //             SizedBox(height: 10),
  //             CustomTextField(controller: latCtrl, labelText: 'Latitude', keyboardType: TextInputType.number),
  //             SizedBox(height: 10),
  //             CustomTextField(controller: lngCtrl, labelText: 'Longitude', keyboardType: TextInputType.number),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel',
  //         style: TextStyle(color: Colors.blue))),
  //         ElevatedButton(
  //           onPressed: () async {
  //             await FirebaseFirestore.instance.collection('mosques').add({
  //               'name': nameCtrl.text.trim(),
  //               'address': addressCtrl.text.trim(),
  //               'lat': double.parse(latCtrl.text),
  //               'lng': double.parse(lngCtrl.text),
  //               'createdAt': FieldValue.serverTimestamp(),
  //             });
  //             Colors.green.shade600;

  //             Navigator.pop(context);
  //             _loadMosques(); // refresh list
  //           },
  //           child: const Text('Save'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAddMosqueSheet() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    LatLng? selectedLatLng;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(Icons.mosque, size: 40, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Add Mosque',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: nameCtrl,
                    labelText: 'Mosque Name',
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: addressCtrl,
                    labelText: 'Address (optional)',
                  ),
                  const SizedBox(height: 16),

                  // 📍 LOCATION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.my_location),
                          label: const Text('Use Current Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final pos = await _getCurrentLatLng();
                            if (pos != null) {
                              setModalState(() => selectedLatLng = pos);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Pick Location on Map'),
                    onPressed: () async {
                      final picked = await _openMapPicker();
                      if (picked != null) {
                        setModalState(() => selectedLatLng = picked);
                      }
                    },
                  ),

                  if (selectedLatLng != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Location selected ✔',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (nameCtrl.text.trim().isEmpty) {
                                _showErrorSnackbar('Please enter mosque name');
                                return;
                              }

                              if (selectedLatLng == null) {
                                _showErrorSnackbar(
                                  'Please select mosque location',
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);

                              await FirebaseFirestore.instance
                                  .collection('mosques')
                                  .add({
                                    'name': nameCtrl.text.trim(),
                                    'address': addressCtrl.text.trim(),
                                    'lat': selectedLatLng!.latitude,
                                    'lng': selectedLatLng!.longitude,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                              Navigator.pop(context);
                              _loadMosques();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save Mosque'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<LatLng?> _getCurrentLatLng() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      _showErrorSnackbar('Location permission denied');
      return null;
    }
  }

  Future<LatLng?> _openMapPicker() async {
    return await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const MapPickerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      // resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Mosque', style: TextStyle(color: Colors.white)),
        onPressed: _showAddMosqueSheet,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // FIXED: Custom App Bar - Removed title from FlexibleSpaceBar
            SliverAppBar(
              expandedHeight: height * 0.20,
              floating: false,
              pinned: true,
              backgroundColor: Colors.green.shade600,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              // FIXED: Title moved here instead of FlexibleSpaceBar
              title: const Text(
                'Mosques',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                // Search Toggle
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _filterMosques();
                      }
                    });
                  },
                ),
                // View Toggle
                IconButton(
                  icon: Icon(
                    _isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
                // Sort Button
                IconButton(
                  icon: const Icon(Icons.sort_rounded, color: Colors.white),
                  onPressed: _showSortOptions,
                ),
              ],
              // FIXED: FlexibleSpaceBar without title
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(gradient: AppColor.primaryGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: kToolbarHeight + height * 0.01,
                        left: width * 0.05,
                        right: width * 0.05,
                        bottom: height * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Header Content
                          Row(
                            children: [
                              Container(
                                width: width * 0.14,
                                height: width * 0.14,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.mosque_rounded,
                                  color: Colors.white,
                                  size: width * 0.08,
                                ),
                              ),
                              SizedBox(width: width * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Nearby Mosques',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      '${_filteredMosques.length} mosques available',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: width * 0.033,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar
            if (_isSearching)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(width * 0.04),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search mosques by name or address...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: width * 0.038,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[600],
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterMosques();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.018,
                        ),
                      ),
                      style: TextStyle(fontSize: width * 0.04),
                    ),
                  ),
                ),
              ),

            // Stats Bar
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.015,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_filteredMosques.length} of ${_allMosques.length} mosques',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: width * 0.032,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: width * 0.035,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: width * 0.01),
                          Text(
                            _sortBy == 'name' ? 'By Name' : 'By Address',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: width * 0.028,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (isLoading)
              SliverFillRemaining(child: _buildLoadingState(width, height))
            else if (hasError)
              SliverFillRemaining(child: _buildErrorState(width, height))
            else if (_filteredMosques.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(width, height))
            else if (_isGridView)
              _buildGridView(width, height)
            else
              _buildListView(width, height),
          ],
        ),
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState(double width, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.2,
            height: width * 0.2,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade600,
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
          Text(
            'Loading mosques...',
            style: TextStyle(color: Colors.grey[600], fontSize: width * 0.04),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState(double width, double height) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: width * 0.25,
              height: width * 0.25,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: width * 0.12,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: height * 0.025),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: height * 0.03),
            ElevatedButton.icon(
              onPressed: _loadMosques,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: height * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(double width, double height) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(width * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.25,
                height: width * 0.25,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: width * 0.12,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: height * 0.025),
              Text(
                'No mosques found',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Try adjusting your search or filters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.035,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: height * 0.03),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _filterMosques();
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade600,
                  side: BorderSide(color: Colors.green.shade600),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: height * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List View
  Widget _buildListView(double width, double height) {
    return SliverPadding(
      padding: EdgeInsets.all(width * 0.04),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final mosque = _filteredMosques[index];
          return _MosqueListCard(
            mosque: mosque,
            index: index,
            width: width,
            height: height,
            onTap: () => _showMosqueOptions(mosque),
          );
        }, childCount: _filteredMosques.length),
      ),
    );
  }

  // Grid View
  Widget _buildGridView(double width, double height) {
    return SliverPadding(
      padding: EdgeInsets.all(width * 0.04),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: width * 0.03,
          mainAxisSpacing: width * 0.03,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final mosque = _filteredMosques[index];
          return _MosqueGridCard(
            mosque: mosque,
            index: index,
            width: width,
            height: height,
            onTap: () => _showMosqueOptions(mosque),
          );
        }, childCount: _filteredMosques.length),
      ),
    );
  }
}

// Mosque List Card Widget
class _MosqueListCard extends StatelessWidget {
  final Mosque mosque;
  final int index;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _MosqueListCard({
    required this.mosque,
    required this.index,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.015),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Row(
                children: [
                  // Mosque Icon
                  Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    decoration: BoxDecoration(
                      gradient: AppColor.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: width * 0.08,
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  // Mosque Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          style: TextStyle(
                            fontSize: width * 0.042,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: height * 0.006),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: width * 0.04,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: width * 0.01),
                            Expanded(
                              child: Text(
                                mosque.address,
                                style: TextStyle(
                                  fontSize: width * 0.032,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.008),
                        // Navigate Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.025,
                            vertical: height * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_rounded,
                                size: width * 0.035,
                                color: Colors.green.shade700,
                              ),
                              SizedBox(width: width * 0.01),
                              Text(
                                'Tap for options',
                                style: TextStyle(
                                  fontSize: width * 0.028,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow Icon
                  Container(
                    width: width * 0.1,
                    height: width * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[600],
                      size: width * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Mosque Grid Card Widget
class _MosqueGridCard extends StatelessWidget {
  final Mosque mosque;
  final int index;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _MosqueGridCard({
    required this.mosque,
    required this.index,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(width * 0.035),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mosque Icon
                  Container(
                    width: width * 0.18,
                    height: width * 0.18,
                    decoration: BoxDecoration(
                      gradient: AppColor.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: width * 0.09,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  // Name
                  Text(
                    mosque.name,
                    style: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.008),
                  // Address
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: width * 0.035,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: width * 0.01),
                      Flexible(
                        child: Text(
                          mosque.address,
                          style: TextStyle(
                            fontSize: width * 0.028,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.012),
                  // Navigate Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: height * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: width * 0.035,
                          color: Colors.green.shade700,
                        ),
                        SizedBox(width: width * 0.01),
                        Text(
                          'Navigate',
                          style: TextStyle(
                            fontSize: width * 0.028,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Option Tile Widget for Bottom Sheet
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double width;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.01,
      ),
      leading: Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: width * 0.06),
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
        style: TextStyle(fontSize: width * 0.032, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey[400],
        size: width * 0.06,
      ),
    );
  }
}

// Sort Option Widget
class _SortOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: width * 0.1,
        height: width * 0.1,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.green.shade600 : Colors.grey[600],
          size: width * 0.05,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.green.shade700 : Colors.grey[800],
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: Colors.green.shade600,
              size: width * 0.06,
            )
          : null,
    );
  }
}

// Mosque Model
class Mosque {
  final String name;
  final double lat;
  final double lng;
  final String address;

  Mosque({
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required String id,
  });

  factory Mosque.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mosque(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Mosque',
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      address: data['address'] ?? 'No address provided',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // factory Mosque.fromJson(Map<String, dynamic> json) {
  //   return Mosque(
  //     name: json['name'],
  //     lat: json['lat'],
  //     lng: json['lng'],
  //     address: json['address'],
  //   );
  // }
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng selected = const LatLng(25.3960, 68.3578);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Mosque Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: selected, zoom: 16),
        onTap: (pos) => setState(() => selected = pos),
        markers: {
          Marker(markerId: const MarkerId('picked'), position: selected),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, selected),
        icon: const Icon(Icons.check),
        label: const Text('Confirm Location'),
      ),
    );
  }
}
