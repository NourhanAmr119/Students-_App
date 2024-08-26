// ignore_for_file: unused_import

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'edit_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'signup.dart';
import 'user_data.dart';


void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Local Database Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUp(),
        '/main': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),  
        '/edit': (context) => const EditPage(),
      },
    );
  }
}