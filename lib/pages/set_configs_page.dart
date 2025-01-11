import 'package:flutter/material.dart';

class SetConfigsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Add logic for time button action
                Navigator.pushReplacementNamed(context, '/game');
              },
              icon: Icon(Icons.access_time),
              label: Text('Time'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add logic for score button action
                Navigator.pushReplacementNamed(context, '/game');
              },
              icon: Icon(Icons.score),
              label: Text('Score'),
            ),
          ],
        ),
      ),
    );
  }
}