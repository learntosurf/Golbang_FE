import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golbang/pages/logins/hi_screen.dart';
import 'package:golbang/pages/signup/signup.dart';
import 'package:golbang/pages/signup/signup_complete.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:golbang/pages/home/home_page.dart';
import 'package:golbang/pages/game/score_card_page.dart';
/*
import 'screens/logins/hi_screen.dart';
import 'screens/logins/signup.dart';
import 'screens/logins/signup_complete.dart';
*/
Future<void> main() async {
  await dotenv.load(fileName: 'assets/config/.env');
  // 날짜 형식화를 초기화한 후 앱을 시작합니다.
  initializeDateFormatting().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserTokenProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
          title: 'GOLBANG MAIN PAGE',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              foregroundColor: Colors.black,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          home: const HiScreen(),
          routes: {
            '/signup': (context) => SignUpPage(),
            '/signupComplete': (context) => const SignupComplete(),
          },
        )
    );
  }
}
