import 'package:flutter/material.dart';
import 'login_page.dart';  
import 'bottom_app_bar.dart';
 
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the home page!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onProfilePressed: () {
          // Navigate to the profile page
          Navigator.pushReplacementNamed(context, '/profile');
        },
        onHomePressed: () {
          // Navigate to the home page
          Navigator.pushReplacementNamed(context, '/main');
        },
      ), // Use CustomBottomAppBar
    );
  }
}