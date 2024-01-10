import 'package:flutter/material.dart';
import 'package:magento_flutter/screen/categories.dart';

class HomeTabsNew extends StatelessWidget {
  const HomeTabsNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magento Shop'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesScreen(),
                )),
            child: const Text('All Categories')),
      ),
    );
  }
}
