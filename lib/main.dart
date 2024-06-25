import 'package:flutter/material.dart';
import 'package:gmlkit_liveness/presentation/home_page/home_page.dart';
import 'package:gmlkit_liveness/presentation/live_data_page/live_data_page.dart';

void main() {
  runApp(const GMLKitLiveness());
}

class GMLKitLiveness extends StatelessWidget {
  const GMLKitLiveness({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = {
      '/': (_) => const HomePage(),
      '/live-data': (_) => const LiveDataPage(),
    };

    return MaterialApp(
      title: 'Flutter Liveness',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: routes,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 26, 255, 0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return child!;
      },
    );
  }
}
