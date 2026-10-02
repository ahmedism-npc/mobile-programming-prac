import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Row and Column',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Row and Column'),
        backgroundColor: Colors.amber,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Baris pertama (2 kotak)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KotakBiru(
                  warna: Color(0xFF90CAF9), // Blue 200
                  label: 'Suka 1',
                ),
                SizedBox(width: 20), // Jarak horizontal
                KotakBiru(
                  warna: Color(0xFF42A5F5), // Blue 400
                  label: 'Suka 2',
                ),
              ],
            ),
            SizedBox(height: 20), // Jarak vertikal antar baris
            // Baris kedua (2 kotak)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KotakBiru(
                  warna: Color(0xFF1E88E5), // Blue 600
                  label: 'Suka 3',
                ),
                SizedBox(width: 20), // Jarak horizontal
                KotakBiru(
                  warna: Color(0xFF0D47A1), // Blue 900
                  label: 'Suka 4',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget kustom untuk kotak dengan icon favorite dan teks
class KotakBiru extends StatelessWidget {
  final Color warna;
  final String label;

  const KotakBiru({
    super.key,
    required this.warna,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black26,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 36,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
