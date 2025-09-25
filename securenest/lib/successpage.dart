import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'upload_file.dart';

class SuccessPage extends StatefulWidget {
  final bool isLogin; // true if login, false if signup

  const SuccessPage({super.key, required this.isLogin});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    // Redirect after 2.5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UploadPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.isLogin
        ? "Successfully logged in!"
        : "Account created successfully!";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Tickmark
            Lottie.asset(
              "assets/success_tick.json", // download a tickmark lottie
              width: 150,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
