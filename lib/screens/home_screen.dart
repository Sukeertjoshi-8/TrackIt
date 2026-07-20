import 'package:flutter/material.dart';
import '../widgets/timeline_view.dart';
import '../widgets/month_view.dart';
import '../widgets/year_view.dart';
import '../widgets/analytics_dashboard.dart';
import '../widgets/add_task_modal.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _showAddTaskModal() {
    TaskCategory initialCategory = TaskCategory.day;
    if (_currentIndex == 1) initialCategory = TaskCategory.month;
    if (_currentIndex == 2) initialCategory = TaskCategory.year;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskModal(initialCategory: initialCategory),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF9C27B0) : Colors.grey.shade400;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            TimelineView(),
            MonthView(),
            YearView(),
            AnalyticsDashboard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        backgroundColor: const Color(0xFF9C27B0), // Purple FAB
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 20,
        shadowColor: Colors.black12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(
              icon: Icons.wb_sunny_outlined,
              activeIcon: Icons.wb_sunny,
              label: 'Today',
              index: 0,
            ),
            _buildBottomNavItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: 'Month',
              index: 1,
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildBottomNavItem(
              icon: Icons.flag_outlined,
              activeIcon: Icons.flag,
              label: 'Year',
              index: 2,
            ),
            _buildBottomNavItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              label: 'Analytics',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}
