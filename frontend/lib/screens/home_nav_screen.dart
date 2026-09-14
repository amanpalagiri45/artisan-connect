import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../state/auth_provider.dart';
import '../state/notification_provider.dart';
import 'catalog/catalog_screen.dart';
import 'dashboard/artisan_dashboard_screen.dart';
import 'notifications/notification_screen.dart';
import 'auth/login_screen.dart';

class HomeNavScreen extends StatefulWidget {
  const HomeNavScreen({Key? key}) : super(key: key);

  @override
  State<HomeNavScreen> createState() => _HomeNavScreenState();
}

class _HomeNavScreenState extends State<HomeNavScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start background polling for notifications
      Provider.of<NotificationProvider>(context, listen: false).startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProv = Provider.of<NotificationProvider>(context);

    final screens = [
      const CatalogScreen(),
      auth.isArtisan
          ? const ArtisanDashboardScreen()
          : _buildBuyerOrGuestDashboard(auth),
      const NotificationScreen(),
      _buildProfileScreen(auth),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppTheme.primaryTerracotta.withOpacity(0.18),
        backgroundColor: Colors.white,
        elevation: 3,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: AppTheme.primaryTerracotta),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard, color: AppTheme.primaryTerracotta),
            label: auth.isArtisan ? 'Dashboard' : 'Linkages',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: notifProv.unreadCount > 0,
              label: Text('${notifProv.unreadCount}'),
              backgroundColor: AppTheme.primaryTerracotta,
              child: const Icon(Icons.notifications_none_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: notifProv.unreadCount > 0,
              label: Text('${notifProv.unreadCount}'),
              backgroundColor: AppTheme.primaryTerracotta,
              child: const Icon(Icons.notifications, color: AppTheme.primaryTerracotta),
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppTheme.primaryTerracotta),
            label: auth.isAuthenticated ? 'Account' : 'Sign In',
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerOrGuestDashboard(AuthProvider auth) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Linkages'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.handshake_outlined, color: AppTheme.primaryTerracotta, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Direct Sourcing & Linkages',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'As a conscious buyer or retail procurement partner, you can connect directly with verified indigenous artisans without predatory intermediaries.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (!auth.isAuthenticated)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In to Create Linkages'),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.sageAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Logged in as Buyer: ${auth.currentUser?.fullName}. Browse the Catalog to submit direct procurement inquiries to craftspeople.',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.sageAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen(AuthProvider auth) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!auth.isAuthenticated) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 64, color: AppTheme.textSecondary),
                    const SizedBox(height: 16),
                    const Text('Join Artisan Connect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to list handcrafted creations or send procurement inquiries to traditional artisans.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text('Sign In / Register'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryTerracotta.withOpacity(0.15),
                      child: Text(
                        auth.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auth.currentUser?.fullName ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      auth.currentUser?.email ?? '',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTerracotta.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ROLE: ${auth.currentUser?.role.name.toUpperCase()}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => auth.logout(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
