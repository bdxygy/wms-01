import 'package:flutter/material.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';
import 'product_list_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainNavigationScaffold(
      currentRoute: 'products',
      child: const ProductListScreen(),
    );
  }
}