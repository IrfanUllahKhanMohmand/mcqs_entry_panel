// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:math';

import 'package:mcqs_entry/common/utills/session_box.dart';
import 'package:mcqs_entry/pages/data_entry/data_entry_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool isPasswordVisible = false;
  String generateToken() {
    const String validChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const int tokenLength = 32;

    final Random random = Random();
    final StringBuffer tokenBuffer = StringBuffer();

    for (int i = 0; i < tokenLength; i++) {
      final int randomIndex = random.nextInt(validChars.length);
      tokenBuffer.write(validChars[randomIndex]);
    }

    return tokenBuffer.toString();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text;
    final password = _passwordController.text;

    final url = Uri.parse('https://apis.pkmcqsquiz.com/api/authenticate');
    final response = await http.post(
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        url,
        body: jsonEncode(
            <String, dynamic>{'email': email, 'password': password}));
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['exists']) {
        final sessionToken = generateToken();

        await SessionBox.saveToken(sessionToken);
        // User exists, navigate to next page
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const DataEntryPage();
        }));
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid email or password'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
