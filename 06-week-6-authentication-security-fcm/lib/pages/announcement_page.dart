import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  final String id;
  const AnnouncementPage({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #$id')),
      body: Center(child: Text('Detail isi pengumuman dengan ID: $id')),
    );
  }
}
