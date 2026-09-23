import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeToGame API ListView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber), //
        useMaterial3: true, //
      ),
      home: const MyHomePage(title: 'Daftar Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title}); //

  final String title; //

  @override
  State<MyHomePage> createState() => _MyHomePageState(); //
}

class _MyHomePageState extends State<MyHomePage> {
  // List untuk menampung data game dari endpoint API
  List dataGame = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilData(); // Request data dijalankan langsung saat widget pertama kali dimuat
  }

  // Method request data ke server dengan endpoint API FreeToGame
  Future _ambilData() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.freetogame.com/api/games'), //
      );

      if (response.statusCode == 200) { //
        final data = jsonDecode(response.body); //
        if (mounted) {
          setState(() {
            // Menyimpan hanya 20 data pertama dari API ke dalam List sesuai modul
            dataGame = data.take(20).toList(); //
            isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal load data dari FreeToGame API'); //
      }
    } catch (e) {
      debugPrint('Error: $e'); //
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), //
        backgroundColor: Colors.amber, //
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8), //[cite: 2]
              // Penggunaan ListView.builder untuk memuat item secara efisien[cite: 2]
              child: ListView.builder(
                itemCount: dataGame.length, //[cite: 2]
                itemBuilder: (context, index) { //[cite: 2]
                  return _listItem(
                    dataGame[index]['thumbnail'] ?? 'https://via.placeholder.com/150', //[cite: 2]
                    dataGame[index]['title'] ?? 'Tidak ada judul', //[cite: 2]
                    dataGame[index]['genre'] ?? 'Tidak ada genre', //[cite: 2]
                    dataGame[index]['release_date'] ?? 'Tidak ada tanggal', //[cite: 2]
                  );
                },
              ),
            ),
    );
  }
}

// Fungsi tombol kustom sesuai poin 6.4.d di luar MyHomePageState[cite: 2]
Container _tombolBaca() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15), //[cite: 2]
    decoration: BoxDecoration(
      color: Colors.orange, //[cite: 2]
      borderRadius: BorderRadius.circular(15), //[cite: 2]
    ),
    child: const Text(
      'Baca Info', //[cite: 2]
      style: TextStyle(color: Colors.white), //[cite: 2]
    ),
  );
}

// Fungsi listItem kustom sesuai poin 6.4.e di luar MyHomePageState[cite: 2]
Container _listItem(String url, String judul, String genre, String rilis) {
  return Container(
    padding: const EdgeInsets.all(15), //[cite: 2]
    margin: const EdgeInsets.only(bottom: 10), //[cite: 2]
    decoration: BoxDecoration(
      color: Colors.white, //[cite: 2]
      borderRadius: BorderRadius.circular(15), //[cite: 2]
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [ //[cite: 2]
        ClipRRect(
          borderRadius: BorderRadius.circular(5), //[cite: 2]
          child: Image.network(
            url, //[cite: 2]
            width: 70, //[cite: 2]
            height: 70, //[cite: 2]
            fit: BoxFit.cover, //[cite: 2]
            errorBuilder: (context, error, stackTrace) => Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 10), //[cite: 2]
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
            children: [
              Text(
                judul, //[cite: 2]
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), //[cite: 2]
              ),
              const SizedBox(height: 5), //[cite: 2]
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, //[cite: 2]
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
                    children: [
                      Text(genre, style: const TextStyle(color: Colors.grey)), //[cite: 2]
                      const SizedBox(height: 2), //[cite: 2]
                      Text(rilis, style: const TextStyle(color: Colors.grey)), //[cite: 2]
                    ],
                  ),
                  _tombolBaca(), //[cite: 2]
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}