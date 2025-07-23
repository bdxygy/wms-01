class NavigationUtils {
  static List<String> getRouteNamesForRole(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return [
          'dashboard',
          'products',
          'transactions',
          'stores',
          'users',
          'settings',
        ];
      case 'ADMIN':
        return [
          'dashboard',
          'products',
          'transactions',
          'stores',
          'settings',
        ];
      case 'STAFF':
        return [
          'dashboard',
          'products',
          'checks',
          'settings',
        ];
      case 'CASHIER':
        return [
          'dashboard',
          'products',
          'transactions',
          'settings',
        ];
      default:
        return [
          'dashboard',
          'products',
          'transactions',
          'stores',
          'settings',
        ];
    }
  }
}