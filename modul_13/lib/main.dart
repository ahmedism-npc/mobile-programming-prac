import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Model data yang diterima dari API.
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory Post.fromJson(
    Map<String, dynamic> json, {
    DateTime? createdAt,
  }) {
    return Post(
      id: json['id'] as int,
      userId: (json['userId'] as int?) ?? 1,
      title: json['title'] as String,
      body: json['body'] as String,
      // Waktu lokal aplikasi, bukan timestamp dari server.
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F3F8),
        textTheme: GoogleFonts.montserratTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade900,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _baseUrl =
      'https://jsonplaceholder.typicode.com/posts';

  static const _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Post? createdPost;
  bool _isLoading = false;

  void _showSnackBar(String message, {required bool success}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  // Menangani loading, hasil operasi, serta error secara terpusat.
  Future<void> _performRequest(
    Future<Post?> Function() request,
    String successMessage,
  ) async {
    if (!mounted || _isLoading) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await request();

      if (!mounted) return;

      setState(() {
        createdPost = result;
      });

      _showSnackBar(successMessage, success: true);
    } on TimeoutException {
      _showSnackBar(
        'Permintaan melewati batas waktu. Periksa koneksi internet.',
        success: false,
      );
    } on http.ClientException {
      _showSnackBar(
        'Gagal menghubungi server. Periksa koneksi internet.',
        success: false,
      );
    } catch (error) {
      _showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
        success: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // CREATE: mengirim data baru dengan HTTP POST.
  Future<void> createPost(String title, String body) async {
    await _performRequest(
      () async {
        final response = await http
            .post(
              Uri.parse(_baseUrl),
              headers: _headers,
              body: jsonEncode({
                'title': title,
                'body': body,
                'userId': 1,
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 201) {
          throw Exception(
            'Gagal menambahkan post. HTTP ${response.statusCode}.',
          );
        }

        return Post.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      },
      'Post berhasil ditambahkan!',
    );
  }

  // UPDATE: mengikuti modul, endpoint demo selalu menggunakan ID 1.
  Future<void> updatePost(int id, String title, String body) async {
    final previousPost = createdPost;

    if (previousPost == null || previousPost.id != id) return;

    await _performRequest(
      () async {
        final response = await http
            .put(
              Uri.parse('$_baseUrl/1'),
              headers: _headers,
              body: jsonEncode({
                'id': 1,
                'title': title,
                'body': body,
                'userId': previousPost.userId,
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          throw Exception(
            'Gagal mengupdate post. HTTP ${response.statusCode}.',
          );
        }

        return Post.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
          createdAt: previousPost.createdAt,
        );
      },
      'Post berhasil diupdate!',
    );
  }

  // DELETE: mengirim permintaan hapus, lalu mengosongkan state.
  Future<void> deletePost(int id) async {
    await _performRequest(
      () async {
        final response = await http
            .delete(
              Uri.parse('$_baseUrl/$id'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200 &&
            response.statusCode != 204) {
          throw Exception(
            'Gagal menghapus post. HTTP ${response.statusCode}.',
          );
        }

        return null;
      },
      'Post berhasil dihapus!',
    );
  }

  Future<void> showAddPostDialog() async {
    final input = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const PostFormDialog(),
    );

    if (!mounted || input == null) return;

    await createPost(input['title']!, input['body']!);
  }

  Future<void> showUpdatePostDialog(Post currentPost) async {
    final input = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => PostFormDialog(post: currentPost),
    );

    if (!mounted || input == null) return;

    await updatePost(
      currentPost.id,
      input['title']!,
      input['body']!,
    );
  }

  Future<void> showDeleteConfirmationDialog(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus post ini?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    await deletePost(id);
  }

  String _formatWib(DateTime time) {
    final wib = time.toUtc().add(const Duration(hours: 7));
    return DateFormat("dd MMMM yyyy, HH:mm 'WIB'").format(wib);
  }

  Widget _buildPostCard(Post post) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !_isLoading,
                  onSelected: (value) {
                    if (value == 'update') {
                      showUpdatePostDialog(post);
                    } else if (value == 'delete') {
                      showDeleteConfirmationDialog(post.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'update',
                      child: Text('Update'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.body,
              style: GoogleFonts.openSans(
                fontSize: 18,
                height: 1.5,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 16),
            Text('id: ${post.id}'),
            const SizedBox(height: 8),
            Text('userID: ${post.userId}'),
            const SizedBox(height: 16),
            Text(
              _formatWib(post.createdAt),
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = createdPost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo CRUD client-server'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            Expanded(
              child: post == null
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_outlined,
                              size: 72,
                              color: Colors.indigo.shade900,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Demo CRUD client-server di Flutter',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tekan tombol + untuk menambahkan data.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        100,
                      ),
                      children: [
                        _buildPostCard(post),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : showAddPostDialog,
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Dialog memiliki controller sendiri agar dapat dibersihkan lewat dispose.
class PostFormDialog extends StatefulWidget {
  const PostFormDialog({super.key, this.post});

  final Post? post;

  @override
  State<PostFormDialog> createState() => _PostFormDialogState();
}

class _PostFormDialogState extends State<PostFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.post?.title ?? '',
    );

    _bodyController = TextEditingController(
      text: widget.post?.body ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kolom ini harus diisi.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'body': _bodyController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.post != null;

    return AlertDialog(
      title: Text(isUpdate ? 'Update Post' : 'Tambah Post'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
                textInputAction: TextInputAction.next,
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan',
                ),
                minLines: 1,
                maxLines: 3,
                validator: _requiredText,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isUpdate ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }
}