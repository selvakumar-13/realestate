import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/auth_service.dart';
import '../widgets/property_card.dart';
import '../config/app_colors.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _propertyService = PropertyService();
  final _authService = AuthService();
  
  List<Property> _allProperties = [];
  List<Property> _featuredProperties = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  String _searchType = 'buy';
  String _bhk = '';
  String _budget = '';
  String _locality = '';
  
  late AnimationController _pulseController1;
  late AnimationController _pulseController2;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    
    // Animated background blobs
    _pulseController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _pulseController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController1.dispose();
    _pulseController2.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final allResult = await _propertyService.getAllProperties();
      final featuredResult = await _propertyService.getFeaturedProperties();

      if (allResult['success'] && featuredResult['success']) {
        setState(() {
          _allProperties = allResult['properties'];
          _featuredProperties = featuredResult['properties'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = allResult['message'] ?? 'Failed to load properties';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading properties';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadProperties,
                  color: AppColors.emeraldPrimary,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildHeroSection(),
                        _buildTrustIndicators(),
                        _buildFeaturedProperties(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.emeraldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emeraldPrimary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Text(
                  'EstateHub',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.person_outline, color: AppColors.emeraldPrimary, size: 20),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authService.currentUser?.fullName ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _authService.currentUser?.email ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('My Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HERO SECTION (Exact Figma Design)
  // ============================================================================
  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFECFDF5), // emerald-50
            Colors.white,
            const Color(0xFFEFF6FF), // blue-50
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background blobs
          Positioned(
            top: 80,
            right: 40,
            child: AnimatedBuilder(
              animation: _pulseController1,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.3 + (_pulseController1.value * 0.3),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.emerald200.withOpacity(0.8),
                          AppColors.emerald200.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 80,
            left: 40,
            child: AnimatedBuilder(
              animation: _pulseController2,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.3 + (_pulseController2.value * 0.3),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.shade200.withOpacity(0.8),
                          Colors.blue.shade200.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 60),
            child: Column(
              children: [
                // Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppColors.emeraldPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'TRUSTED BY 10,000+ CUSTOMERS',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.emeraldPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Heading
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Find Your Perfect Home\n'),
                      TextSpan(
                        text: 'Without Any Hassle',
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [AppColors.emeraldPrimary, Colors.blue.shade600],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                const Text(
                  'Discover thousands of verified properties. Get expert assistance and transparent pricing. Your dream home is just a search away.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Search Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slate200.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs
                      Row(
                        children: [
                          Expanded(child: _buildSearchTab('buy', 'Buy')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSearchTab('rent', 'Rent')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSearchTab('flat', 'Flat')),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Location Input
                      const Text('Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) => setState(() => _locality = value),
                        decoration: InputDecoration(
                          hintText: 'Search locality, landmark, or project',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.location_on, color: AppColors.slate400),
                          filled: true,
                          fillColor: AppColors.slate50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.slate200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.slate200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.emeraldPrimary, width: 2),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // BHK and Budget
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('BHK Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _bhk.isEmpty ? null : _bhk,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.slate50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.slate200),
                                    ),
                                  ),
                                  items: ['1', '2', '3', '4+'].map((bhk) {
                                    return DropdownMenuItem(value: bhk, child: Text('$bhk BHK'));
                                  }).toList(),
                                  onChanged: (value) => setState(() => _bhk = value ?? ''),
                                  hint: const Text('Any'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Budget', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _budget.isEmpty ? null : _budget,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.slate50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.slate200),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(value: '0-2500000', child: Text('Up to ₹25 Lacs')),
                                    DropdownMenuItem(value: '2500000-5000000', child: Text('₹25 - 50 Lacs')),
                                    DropdownMenuItem(value: '5000000-10000000', child: Text('₹50 Lacs - 1 Cr')),
                                    DropdownMenuItem(value: '10000000+', child: Text('₹1 Cr+')),
                                  ],
                                  onChanged: (value) => setState(() => _budget = value ?? ''),
                                  hint: const Text('Any'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Quick Filters
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Text('Quick filters:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          ...[
                            'Furnished',
                            'Ready to Move',
                            'Near Metro',
                            'With Parking',
                          ].map((filter) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(filter, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                          )),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Searching: $_searchType in $_locality'),
                                backgroundColor: AppColors.emeraldPrimary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.emeraldPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 10,
                            shadowColor: AppColors.emerald200,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Search Properties', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(String type, String label) {
    final isSelected = _searchType == type;
    return GestureDetector(
      onTap: () => setState(() => _searchType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.emeraldGradient : null,
          color: isSelected ? null : AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald200.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TRUST INDICATORS (Exact Figma Design)
  // ============================================================================
  Widget _buildTrustIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.slate100),
          bottom: BorderSide(color: AppColors.slate100),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildTrustCard(
                icon: Icons.verified_user,
                color: AppColors.emeraldPrimary,
                bgColor: const Color(0xFFD1FAE5),
                title: 'Verified Listings',
                subtitle: '100% verified properties with genuine details',
              ),
              _buildTrustCard(
                icon: Icons.people,
                color: Colors.blue.shade600,
                bgColor: Colors.blue.shade50,
                title: '10,000+ Customers',
                subtitle: 'Trusted by thousands of happy homeowners',
              ),
              _buildTrustCard(
                icon: Icons.emoji_events,
                color: Colors.purple.shade600,
                bgColor: Colors.purple.shade50,
                title: 'Expert Guidance',
                subtitle: 'Professional support at every step',
              ),
              _buildTrustCard(
                icon: Icons.headset_mic,
                color: Colors.orange.shade600,
                bgColor: Colors.orange.shade50,
                title: '24/7 Support',
                subtitle: 'Round the clock customer assistance',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // FEATURED PROPERTIES
  // ============================================================================
  Widget _buildFeaturedProperties() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Properties',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Handpicked properties for you',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Text('View All', style: TextStyle(color: AppColors.emeraldPrimary)),
                label: const Icon(Icons.arrow_forward, size: 16, color: AppColors.emeraldPrimary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _allProperties.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _allProperties.length > 6 ? 6 : _allProperties.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(
                      property: _allProperties[index],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Property details coming soon!'),
                            backgroundColor: AppColors.emeraldPrimary,
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ============================================================================
  // STATES
  // ============================================================================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.emeraldPrimary),
          SizedBox(height: 16),
          Text('Loading properties...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProperties,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldPrimary),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: AppColors.slate400),
          SizedBox(height: 16),
          Text('No properties found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Check back later for new listings!', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}