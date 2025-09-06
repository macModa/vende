import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: PhosphorIcons.house(),
      activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
      label: 'Home',
      route: '/',
    ),
    NavigationItem(
      icon: PhosphorIcons.gridFour(),
      activeIcon: PhosphorIcons.gridFour(PhosphorIconsStyle.fill),
      label: 'Categories',
      route: '/categories',
    ),
    NavigationItem(
      icon: PhosphorIcons.magnifyingGlass(),
      activeIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold),
      label: 'Search',
      route: '/search',
    ),
    NavigationItem(
      icon: PhosphorIcons.shoppingCart(),
      activeIcon: PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill),
      label: 'Cart',
      route: '/cart',
    ),
    NavigationItem(
      icon: PhosphorIcons.user(),
      activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: _navigationItems
              .map((item) => BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(
                        item.icon,
                        size: 24,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(
                        item.activeIcon,
                        size: 24,
                      ),
                    ),
                    label: item.label,
                  ))
              .toList(),
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
              context.go(_navigationItems[index].route);
            }
          },
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
