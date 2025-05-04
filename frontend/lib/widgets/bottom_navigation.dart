import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: const Color.fromARGB(255, 0, 165, 0), // Active icon color
      unselectedItemColor: const Color(0xFF565656), // Inactive icon color
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed, // To keep all labels visible
      items:  [
        BottomNavigationBarItem(
          icon: _buildSvgIcon("/icons/discover.svg", 0),
          label: "Explorer",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("/icons/posts.svg", 1),
          label: "Posts",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("/icons/map.svg", 2),
          label: "Map",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("/icons/voyage.svg", 3),
          label: "Voyages",
        ),
      ],
    );
  }
Widget _buildSvgIcon(String assetName, int index) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Le petit indicateur au-dessus de l'icône
      Container(
        height: 4,
        width: 30,
        decoration: BoxDecoration(
          color: selectedIndex == index ? const Color(0xFF24A500) : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(height: 4), // espace entre indicateur et icône
      SvgPicture.asset(
        assetName,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          selectedIndex == index ? const Color(0xFF24A500) : const Color(0xFFD4D6DD),
          BlendMode.srcIn,
        ),
      ),
    ],
  );
}

}
