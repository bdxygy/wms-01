import 'package:flutter/material.dart';

/// Mixin to handle automatic list refresh when returning from other screens
/// 
/// This mixin provides functionality to automatically refresh list data
/// when returning from create/edit screens, ensuring lists always show
/// the most up-to-date information.
/// 
/// Usage:
/// ```dart
/// class _MyListScreenState extends State<MyListScreen> 
///     with WidgetsBindingObserver, RefreshListMixin<MyListScreen> {
///   
///   @override
///   void initState() {
///     super.initState();
///     setupRefreshListener();
///   }
///   
///   @override
///   void dispose() {
///     disposeRefreshListener();
///     super.dispose();
///   }
///   
///   @override
///   Future<void> refreshData() async {
///     // Implement your refresh logic here
///     await _loadMyData(refresh: true);
///   }
/// }
/// ```
mixin RefreshListMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  bool _shouldRefreshOnResume = false;
  
  /// Setup the refresh listener - call this in initState()
  void setupRefreshListener() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  /// Dispose the refresh listener - call this in dispose()
  void disposeRefreshListener() {
    WidgetsBinding.instance.removeObserver(this);
  }
  
  /// Mark that data should be refreshed when returning to this screen
  void markForRefresh() {
    _shouldRefreshOnResume = true;
  }
  
  /// Override this method to implement your refresh logic
  Future<void> refreshData();
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app returns to foreground and refresh is needed
    if (state == AppLifecycleState.resumed && _shouldRefreshOnResume) {
      _shouldRefreshOnResume = false;
      // Add small delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          refreshData();
        }
      });
    }
  }
  
  /// Call this when navigating to create/edit screens
  /// Returns a Future that completes when the navigation finishes
  Future<R?> navigateAndRefresh<R>(Future<R?> navigation) async {
    markForRefresh();
    final result = await navigation;
    
    // Refresh immediately if still on this screen
    if (mounted) {
      await refreshData();
    }
    
    return result;
  }
}