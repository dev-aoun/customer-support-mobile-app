import 'package:flutter/material.dart';
import '../../auth/data/user_model.dart';
import '../../tickets/presentation/create_ticket_screen.dart';
import '../../tickets/presentation/ticket_list_screen.dart';
import 'dashboard_screen.dart';
import '../../chat/presentation/ai_chat_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'knowledge_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel? user;

  const MainNavigationScreen({super.key, this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4F46E5);

    final screens = [
      DashboardContent(
        user: widget.user,
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      AIChatScreen(
        user: widget.user,
        onBack: () => setState(() => _currentIndex = 0),
        onLogTicket: () => setState(() => _currentIndex = 2),
      ),
      CreateTicketScreen(
        onBack: () => setState(() => _currentIndex = 0),
        onSuccess: () => setState(() => _currentIndex = 3),
      ),
      TicketListScreen(
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      AlertsScreen(
        onBack: () => setState(() => _currentIndex = 0),
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      ProfileScreen(
        user: widget.user,
        onBack: () => setState(() => _currentIndex = 0),
      ),
      KnowledgeScreen(
        onBack: () => setState(() => _currentIndex = 0),
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        padding: const EdgeInsets.only(top: 6, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
              primaryColor: primaryPurple,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.smart_toy_outlined,
              label: 'AI Chat',
              primaryColor: primaryPurple,
              hasDot: true,
            ),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withAlpha(90),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.confirmation_number_outlined,
              label: 'Tickets',
              primaryColor: primaryPurple,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.notifications_none_rounded,
              label: 'Alerts',
              primaryColor: primaryPurple,
              badgeCount: 2,
            ),
            _buildNavItem(
              index: 5,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              primaryColor: primaryPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
    bool hasDot = false,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? primaryColor : const Color(0xFF64748B);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 24),
              if (hasDot)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              if (badgeCount != null)
                Positioned(
                  right: -6,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
