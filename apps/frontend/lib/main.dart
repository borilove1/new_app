import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ScheduleApp());
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule MVP',
      theme: ThemeData(useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        setState(() {
          errorMessage = '로그인 실패: ${response.body}';
        });
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['accessToken'] as String?;
        if (token == null) {
          setState(() {
            errorMessage = '토큰을 받지 못했습니다.';
          });
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(token: token),
            ),
          );
        }
      }
    } catch (error) {
      setState(() {
        errorMessage = '오류 발생: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: Text(isLoading ? '로그인 중...' : '로그인'),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.token});

  final String token;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? healthStatus;
  bool isChecking = false;

  Future<void> checkHealth() async {
    setState(() {
      isChecking = true;
      healthStatus = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/health'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      setState(() {
        healthStatus = '응답 코드: ${response.statusCode} / ${response.body}';
      });
    } catch (error) {
      setState(() {
        healthStatus = '오류 발생: $error';
      });
    } finally {
      setState(() {
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('토큰은 메모리에만 보관됩니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isChecking ? null : checkHealth,
              child: Text(isChecking ? '확인 중...' : '백엔드 연결 테스트'),
            ),
            if (healthStatus != null) ...[
              const SizedBox(height: 12),
              Text(healthStatus!),
            ],
          ],
        ),
      ),
    );
  }
}
