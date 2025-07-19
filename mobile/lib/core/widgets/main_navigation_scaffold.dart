import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import 'bottom_navigation.dart';

class MainNavigationScaffold extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainNavigationScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(MainNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      final routeNames = WMSBottomNavigation.getRouteNamesForRole(user.role);
      final index = routeNames.indexOf(widget.currentRoute);
      if (index != -1) {
        setState(() {
          _currentIndex = index;
        });
      }
    }
  }

  void _onTabTapped(int index) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      final routeNames = WMSBottomNavigation.getRouteNamesForRole(user.role);
      if (index < routeNames.length) {
        final routeName = routeNames[index];
        
        // Navigate to the selected route
        _navigateToRoute(routeName);
        
        setState(() {
          _currentIndex = index;
        });
      }
    }
  }

  void _navigateToRoute(String routeName) {
    // Navigate to the selected route using GoRouter
    context.goNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // Don't show navigation for unauthenticated users
    if (user == null) {
      return widget.child;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: WMSBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// Navigation helper widget for easy integration
class NavigationAwareScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String currentRoute;
  final FloatingActionButton? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const NavigationAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.bottom,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return MainNavigationScaffold(
      currentRoute: currentRoute,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          actions: actions,
          bottom: bottom,
          automaticallyImplyLeading: showBackButton,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
      ),
    );
  }
}