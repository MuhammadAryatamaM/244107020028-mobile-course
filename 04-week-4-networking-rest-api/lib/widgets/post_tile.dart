import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/post.dart';

/// Widget [PostTile] digunakan untuk merender satu baris (item) dari Post.
/// Mengekstrak widget ini membuat ListView.builder menjadi lebih bersih,
/// dapat digunakan ulang di halaman lain (seperti PagedPostPage), dan mudah diuji.
class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostTile({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Menampilkan ID post dalam bentuk avatar lingkaran
      leading: CircleAvatar(child: Text(post.id.toString())),
      // Menampilkan judul post dengan pembatasan 1 baris
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      // Menampilkan isi post dengan pembatasan 2 baris (jika ada body)
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      // Navigasi ke halaman detail jika onTap tidak di-override
      onTap: onTap ?? () => context.push('/post/${post.id}'),
    );
  }
}
