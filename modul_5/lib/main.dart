import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player Card',
      // Sesuai spesifikasi: gunakan ThemeData.dark()
      theme: ThemeData.dark(),
      home: const MusicCardPage(),
    );
  }
}

class MusicCardPage extends StatefulWidget {
  const MusicCardPage({super.key});

  @override
  State<MusicCardPage> createState() => _MusicCardPageState();
}

class _MusicCardPageState extends State<MusicCardPage> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sesuai spesifikasi: AppBar dengan judul 'Sedang memutar' dan centerTitle: true
      appBar: AppBar(
        title: const Text('Sedang memutar'),
        centerTitle: true,
      ),
      body: Center(
        // Bungkus Card di bagian tengah layar
        child: SizedBox(
          width: 320, // Membatasi lebar card agar terlihat proporsional
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Area Cover Album (Piringan Hitam / Album Icon)
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey.shade800,
                          border: Border.all(color: Colors.blueGrey.shade400, width: 6),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.album,
                            size: 40,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // SizedBox untuk jarak tetap antara Cover dan Informasi Lagu
                  const SizedBox(height: 16),

                  // Baris Informasi Lagu dan Tombol Like
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Kolom Teks: Judul dan Artis
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Di sini ada judul lagu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4), // Jarak statis tipis antar teks
                          Text(
                            'Di sini ada nama artis',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      // Spacer: Membagi dan mengisi sisa ruang secara proporsional ke kanan
                      const Spacer(),

                      // Tombol Aksi Like
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.redAccent : Colors.red.shade400,
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}