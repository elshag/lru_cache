import 'package:flutter/material.dart';

import '../ui/cache_playground/cache_playground_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LRU Cache',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const CachePlaygroundPage(),
    );
  }
}

