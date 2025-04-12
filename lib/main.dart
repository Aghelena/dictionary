import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dictionary_page.dart';
import 'register_page.dart';
import 'login_register_page.dart'; // Certifique-se de criar esta página de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDY62_GssXXTOwUJfDhVd-gkd_qwvOXz1Y",
      authDomain: "dicionario-app.firebaseapp.com",
      projectId: "dicionario-app",
      storageBucket: "dicionario-app.appspot.com",
      messagingSenderId: "864107835625",
      appId: "1:864107835625:web:b4f4c67537014b4b798078",
    ),
  );
  runApp(const DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dicionário Inglês',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F6FF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/register': (context) => const RegisterPage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/login': (context) => const LoginPage(), // Adicionando a rota /login
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const DictionaryPage();
        }

        return const RegisterPage();
      },
    );
  }
}
