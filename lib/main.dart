import 'package:flutter/material.dart';
import 'package:learning_app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Kalau udah ada providers, wrap pake MultiProvider:
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (_) => AuthProvider()),
  //     ],
  //     child: const App(),
  //   ),
  // );

  runApp(const App());
}
