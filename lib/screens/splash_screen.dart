import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.auto_awesome, size: 96, color: Color(0xff6366f1)),
            SizedBox(height: 16),
            Text('Nexii',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Chargement...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
