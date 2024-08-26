// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late String _userName = "";
  late String _userEmail = "";
  late String _studentId = "";
  late String _userLevel = "";
  late String _userGender = "";
  File? _imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _studentId = prefs.getString('user_studentId') ?? '';
      _userLevel = prefs.getString('user_level') ?? '';
      _userGender = prefs.getString('user_gender') ?? ''; // Retrieve gender
      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _studentIdController.text = _studentId;
      _levelController.text = _userLevel;
      _genderController.text = _userGender; // Set gender controller text
    });
  }

  Future<void> _saveChanges() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Database db = await _getDatabase();

    // Save changes to local database
    final Map<String, dynamic> userDataUpdates = {
      'name': _nameController.text,
      'level': _levelController.text,
    };
    if (_imageFile != null) {
      final String imagePath = await _saveImageFile(_userEmail);
      userDataUpdates['imagePath'] = imagePath;
    }
    await db.update(
      'user_data',
      userDataUpdates,
      where: 'email = ?',
      whereArgs: [_userEmail],
    );

    // Save changes to shared preferences
    prefs.setString('user_name', _nameController.text);
    prefs.setString('user_level', _levelController.text);

    // Save image file path in SharedPreferences
    if (_imageFile != null) {
      final String imagePath = await _saveImageFile(_userEmail);
      prefs.setString('user_image', imagePath);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully.'),
      ),
    );

    // Navigate back to the profile page
    Navigator.pop(context);
  }

  Future<String> _saveImageFile(String userEmail) async {
    final String directoryPath = await _getImagesDirectoryPath();
    final String filePath =
        '$directoryPath/$userEmail/user_image.png'; // Unique path for each user
    await _imageFile!.copy(filePath);
    return filePath;
  }

  Future<String> _getImagesDirectoryPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imagesDirectoryPath = '${directory.path}/images';
    final Directory imagesDirectory =
        await Directory(imagesDirectoryPath).create(recursive: true);
    return imagesDirectory.path;
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      // Convert the XFile to a File object
      final File imageFile = File(pickedFile.path);

      // Get the directory path to save the image
      final String imagesDirectoryPath = await _getImagesDirectoryPath();

      // Generate a unique file name for the image
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}.png';

      // Define the destination directory path
      final String destinationDirectoryPath =
          '$imagesDirectoryPath/$_userEmail';

      // Create the destination directory if it doesn't exist
      final Directory destinationDirectory =
          Directory(destinationDirectoryPath);
      if (!await destinationDirectory.exists()) {
        await destinationDirectory.create(recursive: true);
      }

      // Define the destination path
      final String destinationPath =
          '$destinationDirectoryPath/$uniqueFileName';

      // Copy the picked image to the destination path
      final File destinationFile = await imageFile.copy(destinationPath);

      // Set the image file
      setState(() {
        _imageFile = destinationFile;
      });

      // Update image file path in SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_image', destinationPath);

      // Update image file path in local database
      final Database db = await _getDatabase();
      await db.update(
        'user_data',
        {'imagePath': destinationPath},
        where: 'email = ?',
        whereArgs: [_userEmail],
      );
    }
  }

  Future<Database> _getDatabase() async {
    final String path = await _localPath;
    return openDatabase(
      '$path/user_data.db',
      version: 1,
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _showImageSourceDialog(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? const Icon(Icons.person, size: 80)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showImageSourceDialog(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentIdController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _levelController,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genderController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                  child: const Text('Change Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _getImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late TextEditingController _passwordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userEmail = prefs.getString('user_email') ?? '';

    final String currentPassword = _passwordController.text;
    final String storedPassword = prefs.getString('user_password') ?? '';

    if (currentPassword != storedPassword) {
      // Current password entered by the user doesn't match the stored password
      // Display an error message and return without saving changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current password is incorrect.'),
        ),
      );
      return;
    }

    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      // New password and confirm password do not match
      // Display an error message and return without saving changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }

    // Proceed with saving changes since the current password is correct
    final Database db = await _getDatabase();

    // Update password in local database
    await db.update(
      'user_data',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [userEmail],
    );

    // Update password in SharedPreferences
    prefs.setString('user_password', newPassword);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully.'),
      ),
    );

    // Clear text fields
    _passwordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<Database> _getDatabase() async {
    final String path = await _localPath;
    return openDatabase(
      '$path/user_data.db',
      version: 1,
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter your current password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter your new password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                hintText: 'Confirm your new password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
