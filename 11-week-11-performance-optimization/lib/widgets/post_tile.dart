import 'package:flutter/material.dart';

import '../data/local/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text('${post.id}')),
          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            post.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
