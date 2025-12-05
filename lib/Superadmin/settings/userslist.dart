import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  String _filterBy = 'all'; // all, active, blocked
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

    // Load users from Firebase
    _loadUsers();

    // Listen to search changes
    _searchController.addListener(_filterUsers);
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Fetch users from Firebase Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final users = snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        isLoading = false;
      });

      _sortUsers();
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load users. Please try again.';
      });
      debugPrint('Error loading users: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty && _filterBy == 'all') {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          // Search filter
          final matchesSearch = query.isEmpty ||
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);

          // Status filter
          final matchesStatus = _filterBy == 'all' ||
              (_filterBy == 'active' && !user.isBlocked) ||
              (_filterBy == 'blocked' && user.isBlocked);

          return matchesSearch && matchesStatus;
        }).toList();
      }
    });

    _sortUsers();
  }

  void _sortUsers() {
    setState(() {
      if (_sortBy == 'name') {
        _filteredUsers.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'email') {
        _filteredUsers.sort((a, b) => a.email.compareTo(b.email));
      } else if (_sortBy == 'date') {
        _filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                _sortUsers();
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.email_outlined,
              title: 'Email',
              isSelected: _sortBy == 'email',
              width: width,
              onTap: () {
                setState(() => _sortBy = 'email');
                _sortUsers();
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.calendar_today_rounded,
              title: 'Registration Date',
              isSelected: _sortBy == 'date',
              width: width,
              onTap: () {
                setState(() => _sortBy = 'date');
                _sortUsers();
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

  void _showFilterOptions() {
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
              'Filter By Status',
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: width * 0.04),
            _SortOption(
              icon: Icons.people_outline_rounded,
              title: 'All Users',
              isSelected: _filterBy == 'all',
              width: width,
              onTap: () {
                setState(() => _filterBy = 'all');
                _filterUsers();
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.check_circle_outline_rounded,
              title: 'Active Users',
              isSelected: _filterBy == 'active',
              width: width,
              onTap: () {
                setState(() => _filterBy = 'active');
                _filterUsers();
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.block_rounded,
              title: 'Blocked Users',
              isSelected: _filterBy == 'blocked',
              width: width,
              onTap: () {
                setState(() => _filterBy = 'blocked');
                _filterUsers();
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

  // Show user options when tapped
  void _showUserOptions(AppUser user) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
            SizedBox(height: height * 0.025),

            // User Info Header
            Row(
              children: [
                Container(
                  width: width * 0.15,
                  height: width * 0.15,
                  decoration: BoxDecoration(
                    gradient: user.isBlocked
                        ? LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                          )
                        : AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    user.isBlocked ? Icons.block_rounded : Icons.person_rounded,
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
                        user.name,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: width * 0.04,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: width * 0.01),
                          Expanded(
                            child: Text(
                              user.email,
                              style: TextStyle(
                                fontSize: width * 0.032,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.005),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.02,
                          vertical: height * 0.003,
                        ),
                        decoration: BoxDecoration(
                          color: user.isBlocked
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isBlocked ? 'Blocked' : 'Active',
                          style: TextStyle(
                            fontSize: width * 0.028,
                            color: user.isBlocked
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

            // Option: View Details
            _OptionTile(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blue,
              title: 'View Details',
              subtitle: 'See full user information',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _showUserDetails(user);
              },
            ),

            // Option: Block/Unblock User
            _OptionTile(
              icon: user.isBlocked ? Icons.check_circle_outline : Icons.block_rounded,
              iconColor: user.isBlocked ? Colors.green : Colors.red,
              title: user.isBlocked ? 'Unblock User' : 'Block User',
              subtitle: user.isBlocked
                  ? 'Restore user access'
                  : 'Restrict user access',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _confirmBlockUnblock(user);
              },
            ),

            // Option: Delete User (Optional)
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: Colors.orange,
              title: 'Delete User',
              subtitle: 'Permanently remove user',
              width: width,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteUser(user);
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

  // Show user details
  void _showUserDetails(AppUser user) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: width * 0.12,
              height: width * 0.12,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: width * 0.06,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                'User Details',
                style: TextStyle(fontSize: width * 0.045),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: user.name,
              width: width,
            ),
            SizedBox(height: height * 0.015),
            _DetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
              width: width,
            ),
            SizedBox(height: height * 0.015),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone ?? 'Not provided',
              width: width,
            ),
            SizedBox(height: height * 0.015),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: _formatDate(user.createdAt),
              width: width,
            ),
            SizedBox(height: height * 0.015),
            _DetailRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: user.isBlocked ? 'Blocked' : 'Active',
              width: width,
              valueColor: user.isBlocked ? Colors.red : Colors.green,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Confirm block/unblock action
  void _confirmBlockUnblock(AppUser user) {
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: width * 0.12,
              height: width * 0.12,
              decoration: BoxDecoration(
                color: user.isBlocked ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                user.isBlocked ? Icons.check_circle : Icons.block,
                color: user.isBlocked ? Colors.green : Colors.red,
                size: width * 0.06,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                user.isBlocked ? 'Unblock User?' : 'Block User?',
                style: TextStyle(fontSize: width * 0.045),
              ),
            ),
          ],
        ),
        content: Text(
          user.isBlocked
              ? 'Are you sure you want to unblock ${user.name}? They will regain access to the app.'
              : 'Are you sure you want to block ${user.name}? They will lose access to the app.',
          style: TextStyle(fontSize: width * 0.038),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleBlockUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isBlocked ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(user.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  // Confirm delete user
  void _confirmDeleteUser(AppUser user) {
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: width * 0.12,
              height: width * 0.12,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: width * 0.06,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                'Delete User?',
                style: TextStyle(fontSize: width * 0.045),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete ${user.name}? This action cannot be undone.',
          style: TextStyle(fontSize: width * 0.038),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Toggle block/unblock user in Firebase
  Future<void> _toggleBlockUser(AppUser user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'isBlocked': !user.isBlocked});

      // Reload users
      await _loadUsers();

      _showSuccessSnackbar(
        user.isBlocked
            ? '${user.name} has been unblocked'
            : '${user.name} has been blocked',
      );
    } catch (e) {
      _showErrorSnackbar('Failed to update user status');
      debugPrint('Error toggling block status: $e');
    }
  }

  // Delete user from Firebase
  Future<void> _deleteUser(AppUser user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).delete();

      // Reload users
      await _loadUsers();

      _showSuccessSnackbar('${user.name} has been deleted');
    } catch (e) {
      _showErrorSnackbar('Failed to delete user');
      debugPrint('Error deleting user: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Calculate stats
    final totalUsers = _allUsers.length;
    final activeUsers = _allUsers.where((u) => !u.isBlocked).length;
    final blockedUsers = _allUsers.where((u) => u.isBlocked).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: height * 0.25,
              floating: false,
              pinned: true,
              backgroundColor: Colors.green.shade600,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'User Management',
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
                        _filterUsers();
                      }
                    });
                  },
                ),
                // Filter Button
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                  onPressed: _showFilterOptions,
                ),
                // Sort Button
                IconButton(
                  icon: const Icon(Icons.sort_rounded, color: Colors.white),
                  onPressed: _showSortOptions,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                  ),
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
                          // Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.people_rounded,
                                  label: 'Total',
                                  value: '$totalUsers',
                                  color: Colors.white,
                                  width: width,
                                ),
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.check_circle_rounded,
                                  label: 'Active',
                                  value: '$activeUsers',
                                  color: Colors.white,
                                  width: width,
                                ),
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.block_rounded,
                                  label: 'Blocked',
                                  value: '$blockedUsers',
                                  color: Colors.white,
                                  width: width,
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
                        hintText: 'Search users by name or email...',
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
                                  _filterUsers();
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
                      'Showing ${_filteredUsers.length} of ${_allUsers.length} users',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: width * 0.032,
                      ),
                    ),
                    Row(
                      children: [
                        if (_filterBy != 'all')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.006,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_list_rounded,
                                  size: width * 0.035,
                                  color: Colors.blue.shade700,
                                ),
                                SizedBox(width: width * 0.01),
                                Text(
                                  _filterBy == 'active' ? 'Active' : 'Blocked',
                                  style: TextStyle(
                                    fontSize: width * 0.028,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_filterBy != 'all') SizedBox(width: width * 0.02),
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
                                _sortBy == 'name'
                                    ? 'By Name'
                                    : _sortBy == 'email'
                                        ? 'By Email'
                                        : 'By Date',
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
                  ],
                ),
              ),
            ),

            // Content
            if (isLoading)
              SliverFillRemaining(
                child: _buildLoadingState(width, height),
              )
            else if (hasError)
              SliverFillRemaining(
                child: _buildErrorState(width, height),
              )
            else if (_filteredUsers.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(width, height),
              )
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
            'Loading users...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: width * 0.04,
            ),
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
              onPressed: _loadUsers,
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
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: width * 0.12,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: height * 0.025),
            Text(
              'No users found',
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
                setState(() => _filterBy = 'all');
                _filterUsers();
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
    );
  }

  // List View
  Widget _buildListView(double width, double height) {
    return SliverPadding(
      padding: EdgeInsets.all(width * 0.04),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final user = _filteredUsers[index];
            return _UserListCard(
              user: user,
              index: index,
              width: width,
              height: height,
              onTap: () => _showUserOptions(user),
            );
          },
          childCount: _filteredUsers.length,
        ),
      ),
    );
  }
}

// User List Card Widget
class _UserListCard extends StatelessWidget {
  final AppUser user;
  final int index;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _UserListCard({
    required this.user,
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
          border: user.isBlocked
              ? Border.all(color: Colors.red.shade200, width: 1.5)
              : null,
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
                  // User Avatar
                  Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    decoration: BoxDecoration(
                      gradient: user.isBlocked
                          ? LinearGradient(
                              colors: [Colors.red.shade400, Colors.red.shade600],
                            )
                          : AppColor.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (user.isBlocked ? Colors.red : Colors.green)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      user.isBlocked ? Icons.block_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: width * 0.08,
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
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
                              Icons.email_outlined,
                              size: width * 0.04,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: width * 0.01),
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: width * 0.032,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.008),
                        // Status Badge
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.025,
                                vertical: height * 0.004,
                              ),
                              decoration: BoxDecoration(
                                color: user.isBlocked
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    user.isBlocked
                                        ? Icons.block_rounded
                                        : Icons.check_circle_rounded,
                                    size: width * 0.035,
                                    color: user.isBlocked
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
                                  SizedBox(width: width * 0.01),
                                  Text(
                                    user.isBlocked ? 'Blocked' : 'Active',
                                    style: TextStyle(
                                      fontSize: width * 0.028,
                                      color: user.isBlocked
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: width * 0.02),
                            Text(
                              'Joined: ${_formatDate(user.createdAt)}',
                              style: TextStyle(
                                fontSize: width * 0.028,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
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
                      Icons.more_vert_rounded,
                      color: Colors.grey[600],
                      size: width * 0.05,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double width;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: width * 0.06),
          SizedBox(height: width * 0.01),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: width * 0.028,
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double width;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width * 0.08,
          height: width * 0.08,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: width * 0.045,
            color: Colors.green.shade600,
          ),
        ),
        SizedBox(width: width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: width * 0.032,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: width * 0.01),
              Text(
                value,
                style: TextStyle(
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Option Tile Widget
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

// App User Model
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isBlocked;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isBlocked,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'No email',
      phone: data['phone'],
      isBlocked: data['isBlocked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}