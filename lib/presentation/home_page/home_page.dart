import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google MLKit Liveness"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/live-data'),
                child: const Card.filled(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("Live data"),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
