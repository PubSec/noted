import 'package:flutter/material.dart';
import 'package:noted/constants/containershape.dart';
import 'package:noted/constants/text_style.dart';

class SupportMe extends StatelessWidget {
  const SupportMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(
          "Support Me",
          style: textStyle(
            family: akira,
            size: 23,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: myContainer(
        child: const Text('''
        Hello! 
        Thank you for using my app.
        If you can please support me here https://www.buymeacoffee.com/notedapp.
        I appreciate it.

        
      '''),
      ),
    );
  }
}
