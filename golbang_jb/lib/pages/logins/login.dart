
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:golbang/pages/home/splash_screen.dart';
import 'package:golbang/pages/logins/widgets/login_widgets.dart';
import 'package:golbang/pages/logins/widgets/social_login_widgets.dart';
import 'package:golbang/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';  // hooks_riverpod 사용
import 'package:http/http.dart' as http;

import '../../repoisitory/secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // final TextEditingController _emailController = TextEditingController(text: 'yoonsh1004z');
  // final TextEditingController _passwordController = TextEditingController(text: 'todwnl@7706');
  final TextEditingController _emailController = TextEditingController(text: 'Kojungbeom');
  final TextEditingController _passwordController = TextEditingController(text: 'Golbang12!@');
  // final TextEditingController _emailController = TextEditingController(text: 'hihello@email.com');
  // final TextEditingController _emailController = TextEditingController(text: 'merrong925@gachon.ac.kr');
  // final TextEditingController _passwordController = TextEditingController(text: '1q2w3e4r!');
  // final TextEditingController _emailController = TextEditingController(text: 'gunoh928@gmail.com');
  // final TextEditingController _passwordController = TextEditingController(text: 'qwer1234!');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoginTitle(),
              const SizedBox(height: 32),
              EmailField(controller: _emailController),
              const SizedBox(height: 16),
              PasswordField(controller: _passwordController),
              const SizedBox(height: 16),
              const ForgotPasswordLink(),
              const SizedBox(height: 32),
              LoginButton(onPressed: _login),
              // const SizedBox(height: 32),
              // const SignInDivider(),
              // const SizedBox(height: 16),
              // const SocialLoginButtons(),
              const SizedBox(height: 32),
              const SignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    String? fcmToken;
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      fcmToken = await messaging.getToken();
      print('FCM 토큰: $fcmToken');
    } catch (e) {
      print('FCM 토큰 가져오기 실패: $e');
    }

    if (_validateInputs(email, password)) {
      try {
        final response = await AuthService.login(
          username: email,
          password: password,
          fcm_token: fcmToken ?? '',
        );
        await _handleLoginResponse(response);
      } catch (e) {
        print('error: $e');
        _showErrorDialog('An error occurred. Please try again.');
      }
    } else {
      _showErrorDialog('Please fill in all fields');
    }
  }

  bool _validateInputs(String email, String password) {
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<void> _handleLoginResponse(http.Response response) async {
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      var accessToken = body['data']['access_token'];
      // SecureStorage 접근
      final storage = ref.watch(secureStorageProvider);
      await storage.saveAccessToken(accessToken);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } else {
      _showErrorDialog('Invalid email or password');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
