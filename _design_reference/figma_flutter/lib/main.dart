import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

void main() => runApp(const LedgerAIApp());

class LedgerAIApp extends StatelessWidget {
  const LedgerAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LedgerAI',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
