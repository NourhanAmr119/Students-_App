import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Function() onProfilePressed;
  final Function() onHomePressed;

  const CustomBottomAppBar({
    super.key,
    required this.onProfilePressed,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: onProfilePressed,
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: onHomePressed,
            icon: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}