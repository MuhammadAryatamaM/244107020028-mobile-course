import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteTile({super.key, required this.note, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: note.dirty
          ? const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.orange,
              semanticLabel: 'Belum tersinkron',
            )
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
