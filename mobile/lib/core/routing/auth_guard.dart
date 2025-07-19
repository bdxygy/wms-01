import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/store_context_provider.dart';
import '../utils/app_config.dart';

enum GuardResult {
  allow,
  redirectToLogin,
  redirectToStoreSelection,
  redirectToDashboard,
  deny,
}

class AuthGuard {
  // Check authentication status for route access
  GuardResult checkAuthentication(BuildContext context, String route) {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      if (AppConfig.isDebugMode) {
        print('🚫 AuthGuard: Not authenticated, redirecting to login');
      }
      return GuardResult.redirectToLogin;
    }
    
    return GuardResult.allow;
  }

  // Check store selection requirement for route access
  GuardResult checkStoreSelection(BuildContext context, String route) {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();
    
    // OWNER users don't need store selection
    if (authProvider.isOwner) {
      return GuardResult.allow;
    }
    
    // Non-owner users must have store selected for protected routes
    if (_requiresStoreSelection(route) && !storeProvider.hasStoreSelected) {
      if (AppConfig.isDebugMode) {
        print('🚫 AuthGuard: Store selection required for $route');
      }
      return GuardResult.redirectToStoreSelection;
    }
    
    return GuardResult.allow;
  }

  // Check role-based access for specific routes
  GuardResult checkRoleAccess(BuildContext context, String route) {
    final authProvider = context.read<AuthProvider>();
    
    // Define route permissions
    final routePermissions = _getRoutePermissions(route);
    
    if (routePermissions.isEmpty) {
      // No specific permissions required
      return GuardResult.allow;
    }
    
    // Check if user has required permissions
    bool hasAccess = false;
    
    for (final permission in routePermissions) {
      switch (permission) {
        case 'canManageUsers':
          hasAccess = authProvider.canManageUsers;
          break;
        case 'canManageStores':
          hasAccess = authProvider.canManageStores;
          break;
        case 'canCreateProducts':
          hasAccess = authProvider.canCreateProducts;
          break;
        case 'canCreateTransactions':
          hasAccess = authProvider.canCreateTransactions;
          break;
        case 'canDeleteData':
          hasAccess = authProvider.canDeleteData;
          break;
        case 'isOwner':
          hasAccess = authProvider.isOwner;
          break;
        case 'isAdmin':
          hasAccess = authProvider.isAdmin;
          break;
        case 'isStaff':
          hasAccess = authProvider.isStaff;
          break;
        case 'isCashier':
          hasAccess = authProvider.isCashier;
          break;
      }
      
      if (hasAccess) break; // At least one permission matches
    }
    
    if (!hasAccess) {
      if (AppConfig.isDebugMode) {
        print('🚫 AuthGuard: Insufficient permissions for $route');
      }
      return GuardResult.deny;
    }
    
    return GuardResult.allow;
  }

  // Comprehensive guard check for any route
  GuardResult guard(BuildContext context, String route) {
    // 1. Check authentication first
    final authResult = checkAuthentication(context, route);
    if (authResult != GuardResult.allow) {
      return authResult;
    }
    
    // 2. Check store selection requirement
    final storeResult = checkStoreSelection(context, route);
    if (storeResult != GuardResult.allow) {
      return storeResult;
    }
    
    // 3. Check role-based access
    final roleResult = checkRoleAccess(context, route);
    if (roleResult != GuardResult.allow) {
      return roleResult;
    }
    
    return GuardResult.allow;
  }

  // Check if route requires store selection
  bool _requiresStoreSelection(String route) {
    const storeRequiredRoutes = [
      '/dashboard',
      '/products',
      '/transactions',
      '/inventory',
      '/reports',
      '/scanner',
    ];
    
    return storeRequiredRoutes.any((requiredRoute) => 
        route.startsWith(requiredRoute));
  }

  // Get required permissions for a route
  List<String> _getRoutePermissions(String route) {
    if (route.startsWith('/admin')) {
      return ['isOwner', 'isAdmin'];
    }
    
    if (route.startsWith('/users')) {
      return ['canManageUsers'];
    }
    
    if (route.startsWith('/stores')) {
      return ['canManageStores'];
    }
    
    if (route.startsWith('/products/create') || 
        route.startsWith('/products/edit')) {
      return ['canCreateProducts'];
    }
    
    if (route.startsWith('/transactions/create') || 
        route.startsWith('/transactions/edit')) {
      return ['canCreateTransactions'];
    }
    
    if (route.contains('/delete')) {
      return ['canDeleteData'];
    }
    
    if (route.startsWith('/reports')) {
      return ['isOwner', 'isAdmin'];
    }
    
    if (route.startsWith('/settings/system')) {
      return ['isOwner'];
    }
    
    // Default: no specific permissions required
    return [];
  }

  // Helper method to check if user can access a specific feature
  static bool canAccessFeature(BuildContext context, String feature) {
    final authProvider = context.read<AuthProvider>();
    
    switch (feature) {
      case 'createProduct':
        return authProvider.canCreateProducts;
      case 'createTransaction':
        return authProvider.canCreateTransactions;
      case 'manageUsers':
        return authProvider.canManageUsers;
      case 'manageStores':
        return authProvider.canManageStores;
      case 'deleteData':
        return authProvider.canDeleteData;
      case 'viewReports':
        return authProvider.isOwner || authProvider.isAdmin;
      case 'systemSettings':
        return authProvider.isOwner;
      default:
        return false;
    }
  }

  // Helper method to check if user needs store selection
  static bool needsStoreSelection(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();
    
    return authProvider.isAuthenticated && 
           !authProvider.isOwner && 
           !storeProvider.hasStoreSelected;
  }

  // Helper method to get redirect route based on auth state
  static String? getRedirectRoute(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();
    
    if (!authProvider.isAuthenticated) {
      return '/login';
    }
    
    if (needsStoreSelection(context)) {
      return '/store-selection';
    }
    
    // If authenticated and has proper context, go to dashboard
    if (authProvider.isOwner || storeProvider.hasStoreSelected) {
      return '/dashboard';
    }
    
    return null;
  }
}