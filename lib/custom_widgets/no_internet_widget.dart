import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoInternetWidget extends StatelessWidget {
  final bool showGoToDraftsButton;

  const NoInternetWidget({this.showGoToDraftsButton = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NatureConnect',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.grey,
              size: 80.0,
            ),
            const SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            if (showGoToDraftsButton)
              ElevatedButton(
                onPressed: () {
                  // Navigate to drafts screen using context.go
                  context.go('/makedraft');
                },
                child: const Text('Go to Drafts'),
              ),
          ],
        ),
      ),
    );
  }
}
