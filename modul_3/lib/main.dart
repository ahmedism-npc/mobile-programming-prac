import 'package:flutter/material.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  // Helper widget untuk membuat kartu perkiraan cuaca per hari
  Widget _buildWeatherItem(String day, IconData icon, String temp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Icon(icon, size: 36, color: Colors.black),
        const SizedBox(height: 8),
        Text(temp, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Malang',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              const Text(
                '25°',
                style: TextStyle(fontSize: 90, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWeatherItem('Minggu', Icons.sunny, '20°C'),
                  _buildWeatherItem('Senin', Icons.cloudy_snowing, '23°C'),
                  _buildWeatherItem('Selasa', Icons.cloud, '22°C'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}