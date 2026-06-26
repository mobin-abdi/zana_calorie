import 'package:flutter/material.dart';
import 'package:zana_calorie/features/history/ui/history.dart';
import 'package:zana_calorie/features/profile/ui/profile.dart';
import 'package:zana_calorie/features/scan/ui/scan.dart';
import 'package:zana_calorie/theme/light_theme.dart';
import 'package:zana_calorie/features/home/ui/home.dart';

class CustomNavigationBar extends StatelessWidget {
  final int activeIndex;

  const CustomNavigationBar({
    super.key,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.grey, width: 2),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(context, index: 0, icon: Icons.home, label: "خانه", targetPage: const HomeScreen()),
          _buildItem(context, index: 1, icon: Icons.camera_alt, label: "اسکن هوشمند", targetPage: const ScanScreen()),
          _buildItem(context, index: 2, icon: Icons.history, label: "تاریخچه", targetPage: const HistoryScreen()),
          _buildItem(context, index: 3, icon: Icons.person, label: "پروفایل", targetPage: const ProfileScreen()),
          ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Widget targetPage,
  }) {
    final isSelected = activeIndex == index;

    return TextButton(
      onPressed: () {
        if (isSelected) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}