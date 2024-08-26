// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Database> _getDatabase() async {
  final String path = await _localPath;
  return openDatabase(
    '$path/user_data.db',
    version: 1,  
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_data(id INTEGER PRIMARY KEY, name TEXT, gender TEXT, email TEXT, studentId TEXT, level TEXT, password TEXT, imagePath TEXT)',
      );
    },
  );
}


  Future<bool> _checkUserExists(String email, String password) async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> users = await db.query(
      'user_data',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty;
  }

  Future<void> _tryLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form isn't valid, don't proceed.
    }

    final userExists = await _checkUserExists(
      emailController.text,
      passwordController.text,
    );

    if (userExists) {
      // Store email, student ID, name, and level in shared preferences
      await _storeUserData(emailController.text);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Successful'),
          content: const Text('You have successfully logged in.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                // Fetch user's name and level
                final userData = await _getUserData(emailController.text);
                if (userData != null) {
                  final name = userData['name'];
                  final level = userData['level'];
                  // Navigate to home page
                  Navigator.pushReplacementNamed(
                    context,
                    '/main',  
                    arguments: {'name': name, 'level': level},
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show failure dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Incorrect email or password.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _storeUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final db = await _getDatabase();
    final List<Map<String, dynamic>> users = await db.query(
      'user_data',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (users.isNotEmpty) {
      final userData = users.first;
      await prefs.setString('user_email', userData['email']);
      await prefs.setString('user_studentId', userData['studentId']);
      await prefs.setString('user_name', userData['name']);  
      await prefs.setString('user_level', userData['level']);
      await prefs.setString('user_gender', userData['gender']);
      await prefs.setString('user_password', userData['password']);
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String email) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> users = await db.query(
      'user_data',
      where: 'email = ?',
      whereArgs: [email],
    );
    return users.isNotEmpty ? users.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _tryLogin(context),
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}