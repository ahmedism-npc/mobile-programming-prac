import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lokasi Saya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Data lokasi yang akan ditampilkan.
  String? _kecamatan;
  String? _kota;

  double? _latitude;
  double? _longitude;

  // Status proses dan pesan kesalahan.
  bool _isLoading = false;
  String? _errorMessage;

  // Mengatur tombol bantuan yang muncul ketika terjadi error.
  bool _showLocationSettings = false;
  bool _showAppSettings = false;

  String? _nonEmpty(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  Future<void> _getLocation() async {
    // Mencegah permintaan lokasi berulang selama proses berlangsung.
    if (_isLoading || !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;

      _kecamatan = null;
      _kota = null;
      _latitude = null;
      _longitude = null;

      _showLocationSettings = false;
      _showAppSettings = false;
    });

    try {
      // 1. Memeriksa apakah layanan lokasi perangkat aktif.
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showLocationSettings = true;

        throw Exception(
          'Layanan lokasi tidak aktif. '
          'Aktifkan GPS, kemudian coba kembali.',
        );
      }

      // 2. Memeriksa izin akses lokasi.
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showAppSettings = true;

        throw Exception(
          'Izin lokasi ditolak permanen. '
          'Buka pengaturan aplikasi dan izinkan akses lokasi.',
        );
      }

      final permissionGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (!permissionGranted) {
        throw Exception(
          'Izin lokasi belum diberikan. '
          'Tekan tombol kembali dan izinkan akses lokasi.',
        );
      }

      // 3. Mengambil koordinat perangkat.
      // Batas waktu mencegah loading lokasi berlangsung tanpa batas.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      if (!mounted) {
        return;
      }

      // Simpan koordinat lebih dahulu.
      // Koordinat tetap dapat ditampilkan jika pencarian alamat gagal.
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // 4. Mengubah koordinat menjadi informasi alamat.
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 20));

      if (placemarks.isEmpty) {
        throw Exception(
          'Koordinat berhasil diperoleh, '
          'tetapi informasi alamat tidak ditemukan.',
        );
      }

      final place = placemarks.first;

      // Mengikuti konsep label gabungan pada modul.
      // Rincian wilayah dari penyedia geocoding dapat bervariasi.
      final kecamatan =
          _nonEmpty(place.subLocality) ??
          _nonEmpty(place.locality);

      final kota = _nonEmpty(place.subAdministrativeArea);

      if (kecamatan == null && kota == null) {
        throw Exception(
          'Koordinat berhasil diperoleh, tetapi rincian '
          'kelurahan/kecamatan dan kota belum tersedia.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _kecamatan = kecamatan;
        _kota = kota;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _latitude == null
            ? 'Pengambilan koordinat melewati batas waktu. '
                'Pastikan GPS aktif dan coba di tempat terbuka.'
            : 'Koordinat berhasil diperoleh, tetapi pencarian '
                'alamat melewati batas waktu. '
                'Periksa koneksi internet lalu coba kembali.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      // Tetap dijalankan ketika proses berhasil maupun gagal.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openSettings({
    required bool locationSettings,
  }) async {
    try {
      final opened = locationSettings
          ? await Geolocator.openLocationSettings()
          : await Geolocator.openAppSettings();

      if (!mounted) {
        return;
      }

      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengaturan tidak dapat dibuka. '
              'Silakan buka melalui Pengaturan perangkat.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal membuka pengaturan. '
            'Silakan buka melalui Pengaturan perangkat.',
          ),
        ),
      );
    }
  }

  Widget _buildLocationContent() {
    // Kondisi 1: aplikasi sedang memproses lokasi.
    if (_isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Sedang mengambil lokasi dan mencari alamat...',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Kondisi 2: terjadi kesalahan.
    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 52,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),

          // Tampilkan koordinat jika GPS berhasil,
          // tetapi pencarian alamat gagal.
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 20),
            _buildInfoRow(
              'Latitude',
              _latitude!.toStringAsFixed(6),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Longitude',
              _longitude!.toStringAsFixed(6),
            ),
          ],

          if (_showLocationSettings) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _openSettings(
                locationSettings: true,
              ),
              child: const Text('BUKA PENGATURAN LOKASI'),
            ),
          ],

          if (_showAppSettings) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _openSettings(
                locationSettings: false,
              ),
              child: const Text('BUKA PENGATURAN APLIKASI'),
            ),
          ],
        ],
      );
    }

    // Kondisi 3: belum ada permintaan lokasi.
    if (_latitude == null) {
      return const Column(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: Color(0xFF1A237E),
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Tekan tombol untuk menampilkan lokasi.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Kondisi 4: lokasi berhasil diperoleh.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.location_on,
          color: Color(0xFF1A237E),
          size: 56,
        ),
        const SizedBox(height: 16),
        const Text(
          'Lokasi berhasil ditemukan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoRow(
          'Kelurahan/Kecamatan',
          _kecamatan ?? 'Tidak tersedia',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Kota/Kabupaten',
          _kota ?? 'Tidak tersedia',
        ),
        const Divider(height: 32),
        _buildInfoRow(
          'Latitude',
          _latitude!.toStringAsFixed(6),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Longitude',
          _longitude!.toStringAsFixed(6),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Saya'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 40
                      ? constraints.maxHeight - 40
                      : 0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildLocationContent(),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed:
                              _isLoading ? null : _getLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isLoading
                                ? 'SEDANG MEMPROSES...'
                                : 'TAMPILKAN LOKASI SAAT INI',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aktifkan GPS dan koneksi internet. '
                          'Tekan tombol kembali untuk '
                          'memperbarui lokasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}