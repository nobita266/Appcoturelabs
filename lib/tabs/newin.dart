import 'package:flutter/material.dart';

class NewInTabs extends StatefulWidget {
  const NewInTabs({super.key});
  @override
  _NewInTabsState createState() => _NewInTabsState();
}

class _NewInTabsState extends State<NewInTabs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to My Page!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {},
              child: Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}
