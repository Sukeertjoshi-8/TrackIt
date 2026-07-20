import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 32),
          Center(
            child: CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              animation: true,
              percent: 0.65,
              center: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "65%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
                  ),
                  Text("Completion", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: const Color(0xFF9C27B0),
              backgroundColor: Colors.purple.shade50,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Streaks & Milestones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildNeumorphicStatCard('PPL Split Streak', '4 Days', Icons.fitness_center, Colors.orange),
          const SizedBox(height: 16),
          _buildNeumorphicStatCard('Flutter App Milestone', '60%', Icons.code, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildNeumorphicStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(5, 5)),
          BoxShadow(color: Colors.white, blurRadius: 15, offset: Offset(-5, -5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
