import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import 'dashboard/dashboard_screen.dart';
import 'students/students_screen.dart';
import 'invoices/invoices_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StudentsScreen(),
    const InvoicesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 850;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : _buildDrawer(isDesktop),
      body: Row(
        children: [
          // Sidebar for Desktop
          if (isDesktop) _buildSidebar(isDesktop),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(isDesktop),
                // Screen Content
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDesktop) {
    return Drawer(
      child: _buildSidebar(isDesktop),
    );
  }

  Widget _buildSidebar(bool isDesktop) {
    return Container(
      width: 260,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('E', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Text('EduStream', style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // Menu Items
          _buildMenuItem(0, 'Dashboard', Icons.grid_view_rounded, isDesktop),
          _buildMenuItem(1, 'Students', Icons.people_outline, isDesktop),
          _buildMenuItem(2, 'Fees & Invoices', Icons.receipt_long_outlined, isDesktop),
          _buildMenuItem(3, 'Settings', Icons.settings_outlined, isDesktop),
          
          const Spacer(),
          // Sign Out
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.textSecondary),
                  const SizedBox(width: 16),
                  Text('Sign Out', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      color: AppColors.background,
      child: Row(
        children: [
          if (!isDesktop) ...[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Search Bar
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search anything...',
                  hintStyle: AppTextStyles.bodyMedium,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 24 : 12),
          // Actions
          const Icon(Icons.notifications_none, color: AppColors.textSecondary),
          SizedBox(width: isDesktop ? 24 : 12),
          Row(
            children: [
              if (isDesktop) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Admin Panel', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('School Principal', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(width: 12),
              ],
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                child: const Text('AU', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon, bool isDesktop) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (!isDesktop) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
