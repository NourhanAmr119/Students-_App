// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously, unused_element, unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'user_data.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _gender;
  String? _level;
  File? _imageFile;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Database> _getDatabase() async {
    final String path = await _localPath;
    return openDatabase(
      '$path/user_data.db',
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user_data(id INTEGER PRIMARY KEY, name TEXT, gender TEXT, email TEXT, studentId TEXT, level TEXT, password TEXT, imagePath TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _saveUserDataLocally(UserData userData) async {
    final Database db = await _getDatabase();
    await db.insert(
      'user_data',
      userData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _saveUserDataToSharedPreferences(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData.name);
    await prefs.setString('user_email', userData.email);
    await prefs.setString('user_studentId', userData.studentId);
    await prefs.setString('user_level', userData.level);
    await prefs.setString('user_gender', userData.gender);
    await prefs.setString('user_password', userData.password);
    if (_imageFile != null) {
      final String imagePath = await _saveImageFile();
      await prefs.setString('user_image', imagePath);
    }
  }

  Future<String> _getImagesDirectoryPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imagesDirectoryPath = '${directory.path}/images';
    final Directory imagesDirectory =
        await Directory(imagesDirectoryPath).create(recursive: true);
    return imagesDirectory.path;
  }

  Future<String> _saveImageFile() async {
    final String directoryPath = await _getImagesDirectoryPath();
    final String filePath = '$directoryPath/user_image.png';
    await _imageFile!.copy(filePath);
    return filePath;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final bool emailExists = await _checkEmailExists(email);

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Email already exists. Please use a different email.'),
          ),
        );
      } else {
        final userData = UserData(
          name: _nameController.text,
          gender: _gender ?? '',
          email: email,
          studentId: _studentIdController.text,
          level: _level ?? '',
          password: _passwordController.text,
          imagePath: '',
        );
        await _saveUserDataLocally(userData);
        await _saveUserDataToSharedPreferences(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data saved locally'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  Future<bool> _checkEmailExists(String email) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> users = await db.query(
      'user_data',
      where: 'email = ?',
      whereArgs: [email],
    );
    return users.isNotEmpty;
  }

  // Future<void> _getImage(ImageSource source) async {
  //   final pickedFile = await ImagePicker().pickImage(source: source);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Username',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Text('Gender:'),
                    const SizedBox(width: 12),
                    Radio(
                      value: 'Male',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value.toString();
                        });
                      },
                    ),
                    const Text('Male'),
                    Radio(
                      value: 'Female',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value.toString();
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'studentID@stud.fci-cu.edu.eg',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[a-zA-Z0-9]+@stud\.fci-cu\.edu\.eg$')
                        .hasMatch(value)) {
                      return 'Not valid FCI email (e.g., studentID@stud.fci-cu.edu.eg)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: '202011',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your student ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Text('Level:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _level,
                      onChanged: (value) {
                        setState(() {
                          _level = value;
                        });
                      },
                      items: <String>['1', '2', '3', '4']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
